#!/usr/bin/env ruby
require "bunny"

class FibonacciServer
  def initialize(connection_client)
    @connection = connection_client.new
    @connection.start
    @channel = @connection.create_channel
  end

  def start(queue_name)
    puts " [👍] Starting server!"
    @queue = channel.queue(queue_name)
    @exchange = channel.default_exchange
    subscribe_to_queue
  end

  def stop
    puts " [🛑] Stopping server..."
    channel.close
    connection.close
  end

  def loop_forever_to_keep_main_thread_alive
    loop { sleep 5 }
  end

  private

  attr_reader :channel, :exchange, :queue, :connection

  def subscribe_to_queue
    queue.subscribe do |_delivery_info, properties, body|
      result = fibonacci(body.to_i)

      exchange.publish(
        result.to_s,
        routing_key: properties.reply_to,
        correlation_id: properties.correlation_id
      )
    end
  end

  def fibonacci(value)
    if zero_or_one?(value)
      value
    else
      fibonacci(value - 1) + fibonacci(value - 2)
    end
  end

  def zero_or_one?(number)
    number.zero? || number == 1
  end
end
