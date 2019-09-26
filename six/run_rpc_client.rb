#!/usr/bin/env ruby
require "bunny"
require_relative "./fibonacci_client"

bunny = Bunny.new(automatically_recover: false)

client = FibonacciClient.new(
  server_queue_name: "rpc_queue",
  connection: bunny
)

n = (ARGV[0] || 30).to_i

puts " [📭] Requesting fib(#{n})"

response = client.call(n)

puts " [📫] Got back: #{response}"

client.stop

puts " [👋] \n\n"
