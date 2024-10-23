# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

RSpec.describe ElasticGraph::Warehouse::WarehouseConfig::WarehouseTable, :unit do
  include ElasticGraph::SchemaDefinition::TestSupport

  it "handles non-null scalars and accepts a block during construction" do
    require "elastic_graph/warehouse/schema_definition/api_extension"

    results = define_schema(
      schema_element_name_form: :snake_case,
      extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]
    ) do |s|
      s.json_schema_version 1
      s.object_type "Doc" do |t|
        t.field "id", "ID!"
        # pass a block to exercise the block-yield in WarehouseTable#initialize
        t.warehouse_table "doc" do |_table|
          # no-op
        end
      end
    end

    table = results.warehouse_config.fetch("doc")
    expect(table.fetch("table_schema")).to include("id STRING")
  end

  it "handles arrays of non-null element types" do
    require "elastic_graph/warehouse/schema_definition/api_extension"

    results = define_schema(
      schema_element_name_form: :snake_case,
      extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]
    ) do |s|
      s.json_schema_version 1
      s.object_type "Entry" do |t|
        t.field "tags", "[String!]"
        t.warehouse_table "entry"
      end
    end

    table = results.warehouse_config.fetch("entry")
    expect(table.fetch("table_schema")).to match("tags ARRAY<STRING>")
  end

  it "passes through custom settings in to_config" do
    require "elastic_graph/warehouse/schema_definition/api_extension"

    results = define_schema(
      schema_element_name_form: :snake_case,
      extension_modules: [ElasticGraph::Warehouse::SchemaDefinition::APIExtension]
    ) do |s|
      s.json_schema_version 1
      s.object_type "Event" do |t|
        t.field "id", "ID"
        t.field "createdDate", "Date"
        t.warehouse_table "event", retention_days: 14
      end
    end

    table = results.warehouse_config.fetch("event")
    expect(table.fetch("settings")).to include(retention_days: 14)
  end
end
