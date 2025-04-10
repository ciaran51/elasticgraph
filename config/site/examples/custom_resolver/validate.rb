# Copyright 2024 - 2025 Block, Inc.
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.
#
# frozen_string_literal: true

require "elastic_graph/graphql"
$LOAD_PATH << ::File.join(__dir__, "lib")

yaml_file = ::File.join(__dir__, "local_settings.yaml")
graphql = ElasticGraph::GraphQL.from_yaml_file(yaml_file)

query = ::File.read(::File.join(__dir__, "query.graphql"))
response = graphql.graphql_query_executor.execute(query)
data = response.fetch("data")

unless (1..12).cover?(data.fetch("roll6SidedDice")) && (1..20).cover?(data.fetch("roll10SidedDice"))
  raise <<~EOS
    Got an unexpected response:

    #{::JSON.pretty_generate(response)}
  EOS
end
