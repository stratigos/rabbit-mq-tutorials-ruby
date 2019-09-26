#!/usr/bin/env ruby
require "bunny"

if ARGV.empty?
  abort "Usage: #{$PROGRAM_NAME} [info] [warning] [error]" 
end

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.direct("direct_logs")
queue = channel.queue("", exclusive: true)

ARGV.each do |severity|
  queue.bind(exchange, routing_key: severity)
end

puts " [🛌] Waiting for logs. 🚪💨 To exit press CTRL+C"

begin
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    puts " [📬] #{delivery_info.routing_key}:#{body}"
  end
rescue Interrupt => _
  puts " [⛔] Interrupt detected, closing consumer 🚪..."

  channel.close
  connection.close

  puts " [👋] Connection closed. \n\n"

  exit(0)
end
