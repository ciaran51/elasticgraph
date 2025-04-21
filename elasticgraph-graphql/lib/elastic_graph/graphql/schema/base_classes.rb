# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

module ElasticGraph
  class GraphQL
    class Schema
      class BaseField < ::GraphQL::Schema::Field
        def visible?(context)
          if context[:elastic_graph_schema]&.field_named(owner.graphql_name, graphql_name)&.hidden_from_queries?
            return false
          end

          super
        end
      end

      class BaseObject < ::GraphQL::Schema::Object
        field_class BaseField

        def self.visible?(context)
          if context[:elastic_graph_schema]&.type_named(graphql_name)&.hidden_from_queries?
            context[:elastic_graph_query_tracker].record_hidden_type(graphql_name)
            return false
          end

          super
        end
      end
    end
  end
end
