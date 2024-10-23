# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

RSpec.describe "Additional coverage for edge cases", :unit do
  include ElasticGraph::SchemaDefinition::TestSupport

  describe "FieldType::Object edge cases" do
    it "handles list fields with resolved types that have to_warehouse_field_type in table" do
      require "elastic_graph/warehouse/schema_definition/api_extension"

      # Create a mock resolved type that responds to to_warehouse_field_type
      mock_warehouse_field = instance_double("WarehouseFieldType")
      allow(mock_warehouse_field).to receive(:to_table_type).and_return("INT")

      mock_resolved = instance_double("ResolvedType")
      allow(mock_resolved).to receive(:respond_to?).with(:to_warehouse_field_type).and_return(true)
      allow(mock_resolved).to receive(:to_warehouse_field_type).and_return(mock_warehouse_field)

      mock_type = instance_double("Type")
      allow(mock_type).to receive(:list?).and_return(true)
      allow(mock_type).to receive(:unwrap_list).and_return(mock_type)
      allow(mock_type).to receive(:unwrap_non_null).and_return(mock_type)
      allow(mock_type).to receive(:resolved).and_return(mock_resolved)

      mock_subfield = instance_double("Subfield")
      allow(mock_subfield).to receive(:name).and_return("numbers")
      allow(mock_subfield).to receive(:type).and_return(mock_type)

      field_type = ElasticGraph::Warehouse::WarehouseConfig::FieldType::Object.new(
        type_name: "TestObject",
        subfields: [mock_subfield],
        mapping_options: {},
        json_schema_options: {}
      )

      # Should return ARRAY<INT> for list type in table
      expect(field_type.to_table_type).to eq("STRUCT<numbers ARRAY<INT>>")
    end
  end

  describe "APIExtension edge cases" do
    it "handles object types in on_built_in_types" do
      require "elastic_graph/warehouse/schema_definition/api_extension"

      results = define_schema(schema_element_name_form: :snake_case, extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]) do |s|
        s.json_schema_version 1

        # This will trigger on_built_in_types for built-in object types
        s.object_type "TestType" do |t|
          t.field "id", "ID"
          t.warehouse_table "test_types"
        end
      end

      expect(results.warehouse_config).to have_key("test_types")
    end

    it "handles interface types in on_built_in_types" do
      require "elastic_graph/warehouse/schema_definition/api_extension"

      results = define_schema(schema_element_name_form: :snake_case, extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]) do |s|
        s.json_schema_version 1

        # This will trigger on_built_in_types for interface types
        s.interface_type "TestInterface" do |t|
          t.field "id", "ID"
          t.warehouse_table "test_interfaces"
        end

        s.object_type "TestImpl" do |t|
          t.implements "TestInterface"
          t.field "id", "ID"
        end
      end

      expect(results.warehouse_config).to have_key("test_interfaces")
    end

    it "handles scalar types in on_built_in_types" do
      require "elastic_graph/warehouse/schema_definition/api_extension"

      results = define_schema(schema_element_name_form: :snake_case, extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]) do |s|
        s.json_schema_version 1

        # This will trigger on_built_in_types for scalar types
        s.scalar_type "TestScalar" do |t|
          t.mapping type: "keyword"
          t.json_schema type: "string"
        end

        s.object_type "TestType" do |t|
          t.field "id", "TestScalar"
          t.warehouse_table "test_types"
        end
      end

      expect(results.warehouse_config).to have_key("test_types")
    end
  end

  describe "Patches edge cases" do
    it "handles interface types in generate_warehouse_config" do
      require "elastic_graph/warehouse/schema_definition/api_extension"

      results = define_schema(schema_element_name_form: :snake_case, extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]) do |s|
        s.json_schema_version 1

        # Interface types should be included if they have warehouse_table_def
        s.interface_type "TestInterface" do |t|
          t.field "id", "ID"
          t.warehouse_table "test_interfaces"
        end

        s.object_type "TestImpl" do |t|
          t.implements "TestInterface"
          t.field "id", "ID"
        end
      end

      expect(results.warehouse_config).to have_key("test_interfaces")
    end
  end

  describe "Scalar type edge cases" do
    it "handles scalar types with warehouse_table_options[:type] set" do
      require "elastic_graph/warehouse/schema_definition/api_extension"

      results = define_schema(schema_element_name_form: :snake_case, extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]) do |s|
        s.json_schema_version 1

        s.scalar_type "CustomType" do |t|
          t.mapping type: "keyword"
          t.json_schema type: "string"
          t.warehouse_table type: "BINARY"
        end

        s.object_type "TestType" do |t|
          t.field "custom", "CustomType"
          t.warehouse_table "test_types"
        end
      end

      table = results.warehouse_config.fetch("test_types")
      expect(table.fetch("table_schema")).to include("custom BINARY")
    end
  end
end
