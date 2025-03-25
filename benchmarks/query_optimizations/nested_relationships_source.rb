#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require "bundler/setup"
require "elastic_graph/graphql"
require "fileutils"
require "net/http"
require "yaml"

# Query that exercises nested relationships in the Widget schema
QUERY = <<~GRAPHQL
  query {
    widgets(first: 500) {
      nodes {
        id
        name
        components(first: 500) {
          nodes {
            id
            name
            parts(first: 500) {
              nodes {
                ... on MechanicalPart {
                  id
                  name
                  material
                  manufacturer {
                    id
                    name
                    address {
                      full_address
                    }
                  }
                }
                ... on ElectricalPart {
                  id
                  name
                  voltage
                  manufacturer {
                    id
                    name
                    address {
                      full_address
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
GRAPHQL

def ensure_datastore_running
  uri = URI("http://localhost:9334")
  Net::HTTP.get(uri)
  true
rescue Errno::ECONNREFUSED
  puts "Error: Datastore is not running. Please run:"
  puts "  bundle exec rake elasticsearch:local:daemon 'index_fake_data:widgets[80]'"
  puts
  puts "Then try running this benchmark again."
  exit 1
end

def create_config_file(mode)
  # Load the development config
  config = YAML.load_file("config/settings/development.yaml", aliases: true)

  # Update the resolver mode
  config["graphql"]["nested_relationship_resolver_mode"] = mode.to_s

  # Create tmp directory if it doesn't exist
  FileUtils.mkdir_p("tmp")

  # Write the modified config
  path = "tmp/development_#{mode}.yaml"
  File.write(path, config.to_yaml)
  path
end

def run_benchmark(iterations = 10)
  ensure_datastore_running
  results_by_mode = {}

  [:original, :optimized].each do |mode|
    puts "\nTesting with nested_relationship_resolver_mode: #{mode}"
    puts "------------------------------------------------"

    config_path = create_config_file(mode)
    graphql = ElasticGraph::GraphQL.from_yaml_file(config_path)
    executor = graphql.graphql_query_executor

    times = []
    results = []
    puts "Running #{iterations} iterations..."

    iterations.times do |i|
      time = Benchmark.realtime do
        result = executor.execute(QUERY)
        if result["errors"]
          puts "Query errors: #{result["errors"].inspect}"
          exit 1
        end
      rescue => e
        puts "Error executing query: #{e.message}"
        puts e.backtrace
        exit 1
      end

      times << time
      puts "Iteration #{i + 1}: #{time.round(3)}s"
    end

    avg_time = (times.sum / times.size).round(3)
    std_dev = Math.sqrt(times.map { |t| (t - avg_time)**2 }.sum / times.size).round(3)

    puts "\nResults:"
    puts "  Average time: #{avg_time}s"
    puts "  Standard deviation: #{std_dev}s"
    puts "  Min time: #{times.min.round(3)}s"
    puts "  Max time: #{times.max.round(3)}s"

    results_by_mode[mode] = {
      times: times,
      results: results
    }
  end

  puts "\nComparing results between modes..."
  results_by_mode[:original][:results].each_with_index do |original_result, i|
    optimized_result = results_by_mode[:optimized][:results][i]
    if original_result == optimized_result
      puts "Iteration #{i + 1}: Results match"
    else
      puts "Iteration #{i + 1}: Results differ!"
      puts "Original result hash: #{original_result.hash}"
      puts "Optimized result hash: #{optimized_result.hash}"
      # Write the results to files for inspection
      File.write("tmp/original_result_#{i}.json", JSON.pretty_generate(original_result))
      File.write("tmp/optimized_result_#{i}.json", JSON.pretty_generate(optimized_result))
      puts "Full results written to tmp/original_result_#{i}.json and tmp/optimized_result_#{i}.json"
    end
  end

  puts "\nPerformance Summary:"
  original_times = results_by_mode[:original][:times]
  optimized_times = results_by_mode[:optimized][:times]
  improvement = ((original_times.sum / original_times.size) - (optimized_times.sum / optimized_times.size)) * 1000
  puts "  Average improvement with optimization: #{improvement.round(2)}ms"
end

if $0 == __FILE__
  puts "This benchmark requires the datastore to be running with test data loaded."
  puts "To prepare:"
  puts "  bundle exec rake elasticsearch:local:daemon 'index_fake_data:widgets[80]'"
  puts
  puts "Press enter to continue, or Ctrl+C to exit"
  $stdin.gets

  run_benchmark
end
