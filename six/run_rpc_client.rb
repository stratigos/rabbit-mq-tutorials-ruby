#!/usr/bin/env ruby
require "bunny"
require_relative "./fibonacci_client"

bunny = Bunny.new(automatically_recover: false)

client = FibonacciClient.new(
  server_queue_name: "rpc_queue",
  connection: bunny
)

puts " [📭] Requesting fib(30)"

response = client.call(30)

puts " [📫] Got back: #{response}"

client.stop

puts " [👋] \n\n"
