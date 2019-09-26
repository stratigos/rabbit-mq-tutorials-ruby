#!/usr/bin/env ruby
require "bunny"
require_relative "./fibonacci_server"

begin
  bunny = Bunny.new
  server = FibonacciServer.new(bunny)

  puts " [✅] Awaiting RPC requests"

  server.start("rpc_queue")
  server.loop_forever_to_keep_main_thread_alive
rescue Interrupt => _
  puts " [⛔] Interrupt detected, closing consumer 🚪..."

  server.stop

  puts " [👋] Server shutdown. \n\n"
end
