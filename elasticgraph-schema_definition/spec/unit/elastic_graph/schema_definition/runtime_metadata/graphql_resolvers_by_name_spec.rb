# Copyright 2024 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require_relative "runtime_metadata_support"
require "elastic_graph/spec_support/example_extensions/graphql_resolvers"

module ElasticGraph
  module SchemaDefinition
    RSpec.describe "RuntimeMetadata #graphql_resolvers_by_name" do
      include_context "RuntimeMetadata support"

      it "includes the standard ElasticGraph resolvers" do
        result = graphql_resolvers_by_name

        expect(result.keys).to contain_exactly(
          :get_record_field_value,
          :list_records,
          :nested_relationships,
          :object
        )
      end

      it "includes registered custom resolvers when a field is defined that uses the resolver" do
        result = graphql_resolvers_by_name do |schema|
          schema.register_graphql_resolver :resolver1,
            GraphQLResolver1,
            defined_at: "elastic_graph/spec_support/example_extensions/graphql_resolvers",
            param: 15

          schema.on_root_query_type do |t|
            t.field "foo", "Int" do |f|
              f.resolver = :resolver1
            end
          end
        end

        expect(result.fetch(:resolver1)).to eq(graphql_resolver1(param: 15))
      end

      def graphql_resolvers_by_name(...)
        define_schema(...).runtime_metadata.graphql_resolvers_by_name
      end
    end
  end
end
