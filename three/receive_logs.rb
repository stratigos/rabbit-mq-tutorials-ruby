#!/usr/bin/env ruby

require "bunny"

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.fanout("logs")
queue = channel.queue("", exclusive: true)

queue.bind(exchange)

puts " [*] 🛏 Waiting for logs. 🚪 To exit press CTRL+C"

begin
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] 📬 #{body}"
  end
rescue Interrupt => _
  puts " [👋] CYUH! 💨 "
  channel.close
  connection.close
end
