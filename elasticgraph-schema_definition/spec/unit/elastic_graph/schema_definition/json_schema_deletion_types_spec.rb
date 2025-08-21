# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require "elastic_graph/constants"
require "elastic_graph/spec_support/schema_definition_helpers"
require "support/json_schema_matcher"

module ElasticGraph
  module SchemaDefinition
    RSpec.describe "JSON schema deletion types generation" do
      include_context "SchemaDefinitionHelpers"

      describe "deletion schema generation" do
        it "generates deletion schemas for indexed types with delete support" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "null"
          })
        end

        it "does not generate deletion schemas for indexed types without delete support" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.index "widgets"
            end
          end

          expect(json_schema.dig("$defs")).not_to have_key("WidgetDeletion")
        end

        it "does not generate deletion schemas for non-indexed types" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
            end
          end

          expect(json_schema.dig("$defs")).not_to have_key("WidgetDeletion")
        end

        it "includes routing field in deletion schema when index uses custom routing" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "user_id", "ID!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.route_with "user_id"
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "user_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              }
            },
            "required" => ["user_id"]
          })
        end

        it "includes rollover timestamp field in deletion schema when index uses rollover" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "created_at", "DateTime!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.rollover :monthly, "created_at"
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "created_at" => {"$ref" => "#/$defs/DateTime"}
            },
            "required" => ["created_at"]
          })
        end

        it "includes both routing and rollover fields when both are configured" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "user_id", "ID!"
              t.field "created_at", "DateTime!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.route_with "user_id"
                i.rollover :monthly, "created_at"
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "user_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              },
              "created_at" => {"$ref" => "#/$defs/DateTime"}
            },
            "required" => ["created_at", "user_id"]
          })
        end

        it "handles String fields with proper length restrictions" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "category", "String!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.route_with "category"
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "category" => {
                "allOf" => [
                  {"$ref" => "#/$defs/String"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              }
            },
            "required" => ["category"]
          })
        end

        it "handles non-string fields without length restrictions" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "priority", "Int!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.route_with "priority"
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "priority" => {
                "allOf" => [
                  {"$ref" => "#/$defs/Int"},
                  {"pattern" => "[^ \t\n]+"}
                ]
              }
            },
            "required" => ["priority"]
          })
        end

        it "generates deletion schemas for multiple types with delete support" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.support_deletes!
              end
            end

            s.object_type "Component" do |t|
              t.field "id", "ID!"
              t.field "user_id", "ID!"
              t.field "title", "String!"
              t.index "components" do |i|
                i.route_with "user_id"
                i.support_deletes!
              end
            end
          end

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "null"
          })

          expect(json_schema).to have_json_schema_like("ComponentDeletion", {
            "type" => "object",
            "properties" => {
              "user_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              }
            },
            "required" => ["user_id"]
          })
        end

        it "handles nested routing fields in deletion schema" do
          json_schema = dump_schema do |s|
            s.object_type "NestedData" do |t|
              t.field "workspace_id", "ID!"
              t.field "name", "String"
            end

            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.field "embedded", "NestedData!"
              t.index "widgets" do |i|
                i.route_with "embedded.workspace_id"
                i.support_deletes!
              end
            end
          end

          # Should create WidgetDeletionNestedData type with only workspace_id field
          expect(json_schema).to have_json_schema_like("WidgetDeletionNestedData", {
            "type" => "object",
            "properties" => {
              "workspace_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              }
            },
            "required" => ["workspace_id"]
          })

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "embedded" => {"$ref" => "#/$defs/WidgetDeletionNestedData"}
            },
            "required" => ["embedded"]
          })
        end

        it "handles nested rollover fields in deletion schema" do
          json_schema = dump_schema do |s|
            s.object_type "NestedData" do |t|
              t.field "created_at", "DateTime!"
              t.field "name", "String"
            end

            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.field "embedded", "NestedData!"
              t.index "widgets" do |i|
                i.rollover :monthly, "embedded.created_at"
                i.support_deletes!
              end
            end
          end

          # Should create WidgetDeletionNestedData type with only created_at field
          expect(json_schema).to have_json_schema_like("WidgetDeletionNestedData", {
            "type" => "object",
            "properties" => {
              "created_at" => {"$ref" => "#/$defs/DateTime"}
            },
            "required" => ["created_at"]
          })

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "embedded" => {"$ref" => "#/$defs/WidgetDeletionNestedData"}
            },
            "required" => ["embedded"]
          })
        end

        it "handles both nested routing and rollover fields in deletion schema" do
          json_schema = dump_schema do |s|
            s.object_type "NestedData" do |t|
              t.field "workspace_id", "ID!"
              t.field "created_at", "DateTime!"
              t.field "name", "String"
            end

            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.field "embedded", "NestedData!"
              t.index "widgets" do |i|
                i.route_with "embedded.workspace_id"
                i.rollover :monthly, "embedded.created_at"
                i.support_deletes!
              end
            end
          end

          # Should create WidgetDeletionNestedData type with both workspace_id and created_at fields
          expect(json_schema).to have_json_schema_like("WidgetDeletionNestedData", {
            "type" => "object",
            "properties" => {
              "workspace_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              },
              "created_at" => {"$ref" => "#/$defs/DateTime"}
            },
            "required" => ["created_at", "workspace_id"]
          })

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "embedded" => {"$ref" => "#/$defs/WidgetDeletionNestedData"}
            },
            "required" => ["embedded"]
          })
        end

        it "uses the original type when nested type only contains needed fields" do
          json_schema = dump_schema do |s|
            s.object_type "NestedData" do |t|
              t.field "workspace_id", "ID!"  # Only field, and it's needed for routing
            end

            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.field "embedded", "NestedData!"
              t.index "widgets" do |i|
                i.route_with "embedded.workspace_id"
                i.support_deletes!
              end
            end
          end

          # Should use NestedData directly since it only has the needed field
          expect(json_schema.dig("$defs")).not_to have_key("WidgetDeletionNestedData")

          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "embedded" => {"$ref" => "#/$defs/NestedData"}
            },
            "required" => ["embedded"]
          })
        end

        it "handles complex field schemas with allOf, anyOf, and items containing $ref" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "workspace_id", "ID!"  # This will have allOf with $ref
              t.field "tags", "[String!]!"   # This will have items with allOf + $ref
              t.field "cost", "Money"        # This will have anyOf with $ref
              t.field "options", "WidgetOptions" # This will have direct $ref
              t.index "widgets" do |i|
                i.route_with "options.workspace_id"  # Changed to nested routing to test the complex schema handling
                i.support_deletes!
              end
            end

            s.object_type "Money" do |t|
              t.field "currency", "String!"
              t.field "amount_cents", "Int"
            end

            s.object_type "WidgetOptions" do |t|
              t.field "workspace_id", "ID!"
              t.field "size", "String"
            end
          end

          # The deletion schema should include the options field with nested WidgetOptions
          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "options" => {"$ref" => "#/$defs/WidgetDeletionWidgetOptions"}
            },
            "required" => ["options"]
          })

          # Should create a nested deletion schema for WidgetOptions since it contains more than just workspace_id
          expect(json_schema).to have_json_schema_like("WidgetDeletionWidgetOptions", {
            "type" => "object",
            "properties" => {
              "workspace_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              }
            },
            "required" => ["workspace_id"]
          })
        end

        it "preserves complex field schemas when replacing $ref with deletion type reference" do
          json_schema = dump_schema do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "options", "WidgetOptions" do |f|
                f.json_schema minProperties: 2  # This creates allOf with $ref and minProperties
              end
              t.index "widgets" do |i|
                i.route_with "options.workspace_id"
                i.support_deletes!
              end
            end

            s.object_type "WidgetOptions" do |t|
              t.field "workspace_id", "ID!"
              t.field "size", "String"
            end
          end

          # The deletion schema should preserve the minProperties constraint while replacing the $ref
          expect(json_schema).to have_json_schema_like("WidgetDeletion", {
            "type" => "object",
            "properties" => {
              "options" => {
                "allOf" => [
                  {"$ref" => "#/$defs/WidgetDeletionWidgetOptions"},
                  {"minProperties" => 2}
                ]
              }
            },
            "required" => ["options"]
          })

          # Should create a nested deletion schema for WidgetOptions
          expect(json_schema).to have_json_schema_like("WidgetDeletionWidgetOptions", {
            "type" => "object",
            "properties" => {
              "workspace_id" => {
                "allOf" => [
                  {"$ref" => "#/$defs/ID"},
                  {
                    "maxLength" => DEFAULT_MAX_KEYWORD_LENGTH,
                    "pattern" => "[^ \t\n]+"
                  }
                ]
              }
            },
            "required" => ["workspace_id"]
          })
        end
      end

      def dump_schema(&schema_definition)
        define_schema(
          schema_element_name_form: "snake_case",
          &schema_definition
        ).current_public_json_schema
      end
    end
  end
end
