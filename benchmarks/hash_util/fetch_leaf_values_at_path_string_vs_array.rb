#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require "benchmark/ips"
require "json"

# Implementation copied exactly from HashUtil with two entry points
module PathLookup
  def self.fetch_with_string_path(hash, path, &default)
    do_fetch_leaf_values_at_string_path(hash, path.split("."), 0, &default)
  end

  def self.fetch_with_array_path(hash, parts, &default)
    do_fetch_leaf_values_at_array_path(hash, parts, 0, &default)
  end

  # Copied exactly from HashUtil
  def self.do_fetch_leaf_values_at_string_path(object, path_parts, level_index, &default)
    if level_index == path_parts.size
      if object.is_a?(::Hash)
        raise KeyError, "Key was not a path to a leaf field: #{path_parts.join(".").inspect}"
      else
        return Array(object)
      end
    end

    case object
    when nil
      []
    when ::Hash
      key = path_parts[level_index]
      if object.key?(key)
        do_fetch_leaf_values_at_string_path(object.fetch(key), path_parts, level_index + 1, &default)
      else
        missing_path = path_parts.first(level_index + 1).join(".")
        if default
          Array(default.call(missing_path))
        else
          raise KeyError, "Key not found: #{missing_path.inspect}"
        end
      end
    when ::Array
      object.flat_map do |element|
        do_fetch_leaf_values_at_string_path(element, path_parts, level_index, &default)
      end
    else
      # Note: we intentionally do not put the value (`current_level_hash`) in the
      # error message, as that would risk leaking PII. But the class of the value should be OK.
      raise KeyError, "Value at key #{path_parts.first(level_index).join(".").inspect} is not a `Hash` as expected; " \
        "instead, was a `#{object.class}`"
    end
  end

  def self.do_fetch_leaf_values_at_array_path(object, path_parts, level_index, &default)
    if level_index == path_parts.size
      if object.is_a?(::Hash)
        raise KeyError, "Key was not a path to a leaf field: #{path_parts.inspect}"
      else
        return Array(object)
      end
    end

    case object
    when nil
      []
    when ::Hash
      key = path_parts[level_index]
      if object.key?(key)
        do_fetch_leaf_values_at_array_path(object.fetch(key), path_parts, level_index + 1, &default)
      else
        missing_path = path_parts.first(level_index + 1)
        if default
          Array(default.call(missing_path))
        else
          raise KeyError, "Key not found: #{missing_path.inspect}"
        end
      end
    when ::Array
      object.flat_map do |element|
        do_fetch_leaf_values_at_array_path(element, path_parts, level_index, &default)
      end
    else
      # Note: we intentionally do not put the value (`current_level_hash`) in the
      # error message, as that would risk leaking PII. But the class of the value should be OK.
      raise KeyError, "Value at key #{path_parts.first(level_index).inspect} is not a `Hash` as expected; " \
        "instead, was a `#{object.class}`"
    end
  end
end

# Create a deep hash structure that mimics real-world usage
def build_test_hash(depth: 4, width: 3)
  build_level = lambda do |current_depth, max_depth, width|
    return "leaf_value_#{current_depth}" if current_depth >= max_depth

    hash = {}
    width.times do |i|
      hash["level#{current_depth}_key#{i}"] = build_level.call(current_depth + 1, max_depth, width)
    end
    hash
  end

  build_level.call(0, depth, width)
end

# Create paths that will be used in both formats
def generate_test_paths(depth: 4, width: 3, paths_per_level: 20)
  paths = []

  paths_per_level.times do |p|
    key_parts = []
    0.upto(depth - 2) do |level|
      key_parts << "level#{level}_key#{p % width}"
    end
    key_parts << "level#{depth - 1}_key#{p % width}"
    paths << key_parts
  end

  paths
end

def run_benchmark
  test_hash = build_test_hash(width: 5)
  test_paths = generate_test_paths(width: 5, paths_per_level: 20)
  string_paths = test_paths.map { |parts| parts.join(".") }

  puts "Warming up..."
  puts

  Benchmark.ips do |x|
    x.config(time: 5, warmup: 2)

    x.report("string paths") do |times|
      string_paths.each do |path|
        PathLookup.fetch_with_string_path(test_hash, path)
      end
    end

    x.report("array paths") do |times|
      test_paths.each do |path|
        PathLookup.fetch_with_array_path(test_hash, path)
      end
    end

    x.compare!
  end

  puts "\nMemory usage comparison:"
  puts "----------------------"
  require "memory_profiler"

  string_report = MemoryProfiler.report do
    1000.times do
      string_paths.each do |path|
        PathLookup.fetch_with_string_path(test_hash, path)
      end
    end
  end

  array_report = MemoryProfiler.report do
    1000.times do
      test_paths.each do |path|
        PathLookup.fetch_with_array_path(test_hash, path)
      end
    end
  end

  puts "\nString paths:"
  puts "  Allocated strings: #{string_report.total_allocated}"
  puts "  Allocated memory: #{string_report.total_allocated_memsize} bytes"
  puts "\nArray paths:"
  puts "  Allocated strings: #{array_report.total_allocated}"
  puts "  Allocated memory: #{array_report.total_allocated_memsize} bytes"
end

if $0 == __FILE__
  run_benchmark
end
