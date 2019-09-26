#!/usr/bin/env ruby
require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.direct("direct_logs")
severity = ARGV.shift || "info"
message = ARGV.empty? ? "Hello World!!!" : ARGV.join(" ")

exchange.publish(message, routing_key: severity)

puts " [x] 📭 Sent message: '#{message}'"

connection.close
