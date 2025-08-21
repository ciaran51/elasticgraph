# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require_relative "index_mappings/index_mappings_spec_support"

module ElasticGraph
  module SchemaDefinition
    RSpec.describe "Index delete support" do
      include_context "IndexMappingsSpecSupport"

      describe "support_deletes!" do
        it "includes __deleted field in the mapping when delete support is enabled" do
          mapping = index_mapping_for "widgets" do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.support_deletes!
              end
            end
          end

          expect(mapping.dig("properties", "__deleted")).to eq({"type" => "boolean"})
        end

        it "does not include __deleted field in the mapping when delete support is not enabled" do
          mapping = index_mapping_for "widgets" do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.index "widgets"
            end
          end

          expect(mapping.dig("properties")).not_to have_key("__deleted")
        end

        it "preserves all other standard fields when delete support is enabled" do
          mapping = index_mapping_for "widgets" do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.field "price", "Int"
              t.index "widgets" do |i|
                i.support_deletes!
              end
            end
          end

          expect(mapping.dig("properties")).to include({
            "id" => {"type" => "keyword"},
            "name" => {"type" => "keyword"},
            "price" => {"type" => "integer"},
            "__deleted" => {"type" => "boolean"},
            "__versions" => {"dynamic" => "false", "type" => "object"},
            "__sources" => {"type" => "keyword"}
          })
        end

        it "includes __deleted field in index config when delete support is enabled" do
          configs = index_configs_for "widgets" do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.index "widgets" do |i|
                i.support_deletes!
              end
            end
          end

          config = configs.first
          expect(config.dig("mappings", "properties", "__deleted")).to eq({"type" => "boolean"})
        end

        it "includes __deleted field in index template config when delete support is enabled" do
          configs = index_template_configs_for "widgets" do |s|
            s.object_type "Widget" do |t|
              t.field "id", "ID!"
              t.field "name", "String!"
              t.field "created_at", "DateTime!"
              t.index "widgets" do |i|
                i.rollover :monthly, "created_at"
                i.support_deletes!
              end
            end
          end

          config = configs.first
          expect(config.dig("template", "mappings", "properties", "__deleted")).to eq({"type" => "boolean"})
        end
      end
    end
  end
end
