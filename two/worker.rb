#!/usr/bin/env ruby

require "bunny"

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
queue = channel.queue("helloTwo", durable: true)

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  queue.subscribe(block: true) do |delivery_info, _properties, body|
    puts " [x] Received #{body}"
    sleep(body.count(".").to_i)
    puts " [x] Done"
    channel.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  connection.close
  puts " [👋] You are, once again, no longer listening to me talk!"

  exit(0)
end

