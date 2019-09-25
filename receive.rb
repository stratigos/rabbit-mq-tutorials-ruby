#!/usr/bin/env ruby

require "bunny"

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
queue = channel.queue("hello")

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] Received #{body}"
  end
rescue Interrupt => _
  connection.close
  puts " [👋] You are no longer listening to me talk!"

  exit(0)
end

