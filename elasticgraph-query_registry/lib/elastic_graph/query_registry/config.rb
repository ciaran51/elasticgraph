# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require "elastic_graph/config"

module ElasticGraph
  module QueryRegistry
    class Config < ElasticGraph::Config.define(:path_to_registry, :allow_unregistered_clients, :allow_any_query_for_clients)
      json_schema at: "query_registry",
        properties: {
          path_to_registry: {
            description: "Path to the directory containing the query registry files.",
            type: "string",
            examples: ["config/queries"]
          },
          allow_unregistered_clients: {
            description: "Whether to allow clients that are not registered in the registry.",
            type: "boolean",
            examples: [true, false],
            default: true
          },
          allow_any_query_for_clients: {
            description: "List of client names that are allowed to execute any query, even if not registered.",
            type: "array",
            items: {type: "string"},
            examples: [
              [], # : untyped
              ["admin", "internal"]
            ],
            default: [] # : untyped
          }
        },
        required: ["path_to_registry"]
    end
  end
end
