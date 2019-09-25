#!/usr/bin/env ruby

require "bunny"

message = ARGV.empty? ? 'Hello World!' : ARGV.join(" ")

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel

queue = channel.queue("hello")

queue.publish(message, persistent: true)

puts " [x] Sent #{message}"

connection.close

