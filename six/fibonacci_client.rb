#!/usr/bin/env ruby
require "bunny"
require "thread"

class FibonacciClient
  attr_accessor :call_id, :condition, :lock, :response

  def initialize(
    server_queue_name:,
    connection_client:,
    mutex_factory: Mutex,
    condition_factory: ConditionVariable
  )
    @connection = connection_client
    @connection.start

    @channel = connection.create_channel
    @exchange = channel.default_exchange
    @server_queue_name = server_queue_name

    setup_reply_queue(mutex_factory, condition_factory)
  end

  def call(n)
    puts " [📬] Message Received: #{n} "

    @call_id = generate_naive_uuid

    exchange.publish(
      n.to_s,
      routing_key: server_queue_name,
      correlation_id: call_id,
      reply_to: reply_queue.name
    )

    wait_for_signal
    
    response
  end

  def stop
    puts " [🛑] Stopping Client"

    channel.close
    connection.close
  end

  private

  def setup_reply_queue(lock_klass, condition_klass)
    @lock = lock_klass.new
    @condition = condition_klass.new
    @reply_queue = channel.queue("", exclusive: true)
    that = self

    reply_queue.subscribe do |_delivery_info, properties, body|
      if properties[:correlation_id] == that.call_id
        that.response = body.to_i

        signal_execution_of_call(that)
      end
    end
  end

  def generate_naive_uuid
    "#{rand}#{rand}#{rand}"
  end

  def wait_for_signal
    lock.synchronize { condition.wait(lock) }
  end

  def signal_execution_of_call(ref)
    ref.lock.synchronize { ref.condition.signal }
  end

  attr_accessor :connection,
    :channel, :server_queue_name, :reply_queue, :exchange

end
