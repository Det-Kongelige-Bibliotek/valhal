# -*- encoding : utf-8 -*-
require 'bunny'

# Provides methods for all elements for sending a message over RabbitMQ
module MqHelper
  # Sends a preservation message on the MQ.
  #
  # @param message The preservation request message content to be sent on the preservation destination.
  def self.send_message_to_preservation(message)
    destination = MQ_CONFIG['preservation']['destination']

    MqHelper.send_on_rabbitmq(message, destination, {
        'content_type' => 'application/json',
        'type' => MQ_MESSAGE_TYPE_PRESERVATION_REQUEST
    })
  end

  # @param message The preservation import request message content to be sent on the preservation destination.
  def send_message_to_preservation_import(message)
    destination = MQ_CONFIG['preservation']['destination']

    MqHelper.send_on_rabbitmq(message, destination, {
                                         'content_type' => 'application/json',
                                         'type' => MQ_MESSAGE_TYPE_PRESERVATION_IMPORT_REQUEST
                                     })
  end

  # Retrieve queue name from config file
  def self.get_queue_name(target,type)
    MQ_CONFIG[target][type]
  end

  # Sends a given message at the given destination on the MQ with the uri in the configuration.
  # @param message The message content to send.
  # @param destination The destination on the MQ where the message is sent.
  # @param options Is a hash with header values for the message, e.g. content-type, type.
  # @return True, if the message is sent successfully. Otherwise false
  def self.send_on_rabbitmq(message, destination, options={})
    uri = MQ_CONFIG['mq_uri']
    # logger.info "Sending message '#{message}' on destination '#{destination}' at broker '#{uri}'"

    conn = Bunny.new(uri)
    conn.start

    ch   = conn.create_channel
    q    = ch.queue(destination, :durable => true)

    q.publish(message, :routing_key => destination, :persistent => true, :timestamp => Time.now.to_i,
              :content_type => options['content_type'], :type => options['type']
    )

    begin
      conn.close
    rescue => error
      puts "error closing mq connection: #{error.message}. Current connection status: #{conn.status}"
    end
    true
  end
end