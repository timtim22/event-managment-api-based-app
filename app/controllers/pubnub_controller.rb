class PubnubController < ApplicationController
  require 'pubnub'

  # def send_message
  #   pubnub = Pubnub.new(
  #     subscribe_key: :demo,
  #     publish_key: :demo
  # )
  # end

  # callback = Pubnub::SubscribeCallback.new(
  #     message: ->(envelope) {
  #         puts "MESSAGE: # {puts envelope.result[:data][:message]['msg']}"
  #     },
  #     presence: ->(envelope) {
  #         puts "PRESENCE: #{envelope.result[:data]}"
  #     },
  #     status: lambda do |envelope|
  #       puts "\n\n\n#{envelope.status}\n\n\n"
  
  #         if envelope.error?
  #             puts "ERROR! #{envelope.status[:category]}"
  #         else
  #             puts 'Connected!'
  #             if envelope.status[:last_timetoken] == 0 # Connected!
  #                 pubnub.publish(
  #                     channel: :my_channel,
  #                     message:{ msg: 'hello' }
  #                 )
  #             end
  #         end
  #     end
  # )
  
  # pubnub.add_listener(callback: callback)
  
  # pubnub.subscribe(
  #     channels: :my_channel,
  #     presence: :my_channel
  # )

end
