# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

module ElasticGraph
  module SchemaDefinition
    module Indexing
      # Responsible for building deletion schemas from non-deletion schemas.
      # Deletion schemas are minimal schemas that contain only the fields needed
      # for proper routing and rollover of delete events.
      #
      # @api private
      class DeletionSchemaBuilder
        attr_reader :json_schemas_by_type

        # @param json_schemas_by_type [Hash<String, Hash<String, Object>>] map of type names to their full JSON schemas
        def initialize(json_schemas_by_type)
          @json_schemas_by_type = json_schemas_by_type
        end

        # Builds deletion schemas for all index definitions (filters to only those that support deletes)
        # @param index_defs [Array<Index>] all index definitions
        # @return [Hash<String, Hash<String, Object>>] map of deletion schema names to their JSON schemas
        def build_all_deletion_schemas(index_defs)
          index_defs
            .select(&:supports_deletes)
            .map { |index_def| build_deletion_schemas_for_index(index_def) }
            .reduce({}, :merge)
        end

        private

        # Builds deletion schemas for a single index definition
        # @param index_def [Index] the index definition to build deletion schemas for
        # @return [Hash<String, Hash<String, Object>>] map of deletion schema names to their JSON schemas
        def build_deletion_schemas_for_index(index_def)
          full_schema = json_schemas_by_type.fetch(index_def.indexed_type.name)
          type_name = index_def.indexed_type.name
          main_deletion_type_name = "#{type_name}Deletion"

          required_field_paths = [
            (index_def.routing_field_path if index_def.uses_custom_routing?),
            index_def.rollover_config&.timestamp_field_path
          ].compact

          return {main_deletion_type_name => {"type" => "null"}} if required_field_paths.empty?

          # Group field paths by their first field name
          paths_by_first_field = required_field_paths.group_by { |path| path.first_part.name }

          # Process each field and its associated paths
          schemas_for_nested_fields = paths_by_first_field.filter_map do |field_name, paths|
            build_nested_deletion_schema_for_field(field_name, paths, type_name, full_schema)
          end.to_h

          # Extract only the needed properties from the full schema
          full_properties = full_schema.fetch("properties")

          # Extract only the required properties from the full schema, but use deletion schemas for nested types
          deletion_properties = paths_by_first_field.keys.to_h do |field_name|
            field_schema = full_properties.fetch(field_name)

            # Check if this field references a nested type that has a deletion schema
            deletion_type_name = "#{type_name}Deletion#{extract_ref_type_name(field_schema)}"
            if schemas_for_nested_fields.key?(deletion_type_name)
              [field_name, replace_ref_recursively(field_schema, "#/$defs/#{deletion_type_name}")]
            else
              [field_name, field_schema]
            end
          end

          main_deletion_schema = build_object_schema(main_deletion_type_name, deletion_properties)
          schemas_for_nested_fields.merge({main_deletion_type_name => main_deletion_schema})
        end

        # Builds a nested deletion schema for a single field that may have multiple subpaths
        # @param field_name [String] the name of the first field in the paths
        # @param paths [Array<FieldPath>] the field paths that start with the first field
        # @param root_type_name [String] the name of the root object type
        # @param root_schema [Hash<String, Object>] the full JSON schema for the root type
        # @return [Array<String, Hash<String, Object>>, nil] Name and schema
        def build_nested_deletion_schema_for_field(field_name, paths, root_type_name, root_schema)
          # Filter to only nested paths (more than 1 part)
          nested_paths = paths.select { |path| path.path_parts.size > 1 }
          return if nested_paths.empty?

          # Extract the nested type name from the field schema (handling complex schemas)
          nested_type_name = extract_ref_type_name(root_schema.fetch("properties").fetch(field_name))
          deletion_type_name = "#{root_type_name}Deletion#{nested_type_name}"

          # Get the schema for the nested type
          full_nested_schema = json_schemas_by_type.fetch(nested_type_name)

          # Collect all needed field names from all paths
          needed_field_names = nested_paths.map { |path| path.path_parts[1].name }.uniq.sort

          # Get the properties for all needed fields
          full_properties = full_nested_schema.fetch("properties").except("__typename")
          needed_properties = needed_field_names.zip(full_properties.fetch_values(*needed_field_names)).to_h
          return if needed_properties == full_properties

          [deletion_type_name, build_object_schema(deletion_type_name, needed_properties)]
        end

        def build_object_schema(type_name, properties)
          {
            "type" => "object",
            "properties" => properties.merge("__typename" => FieldType::Object.typename_schema_for(type_name)),
            "required" => properties.keys.sort
          }
        end

        # Extracts the type name from a $ref anywhere in a field schema by recursively searching
        # @param field_schema [Hash<String, Object>] the field schema
        # @return [String, nil] the type name from the first $ref found, or nil if not found
        def extract_ref_type_name(field_schema)
          find_ref_recursively(field_schema).split("/").last
        end

        # Recursively searches for the first $ref in a nested hash/array structure
        # @param obj [Object] the object to search (Hash, Array, or other)
        # @return [String, nil] the first $ref found, or nil if not found
        def find_ref_recursively(object)
          case object
          when ::Hash
            if (ref = object["$ref"])
              ref
            else
              find_ref_recursively(object.values)
            end
          when ::Array
            # Recursively search all items in the array
            object.each do |item|
              if (ref = find_ref_recursively(item))
                return ref
              end
            end
          end
        end

        # Recursively replaces any $ref in a nested hash/array structure with a new value
        # @param obj [Object] the object to process (Hash, Array, or other)
        # @param new_ref [String] the new $ref value to use
        # @return [Object] a new object with $ref values replaced
        def replace_ref_recursively(object, new_ref)
          case object
          when ::Hash
            if object.key?("$ref")
              object.merge("$ref" => new_ref)
            else
              object.transform_values { |value| replace_ref_recursively(value, new_ref) }
            end
          when ::Array
            object.map { |item| replace_ref_recursively(item, new_ref) }
          else
            object
          end
        end
      end
    end
  end
end
