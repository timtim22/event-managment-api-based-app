require "spec_helper"

describe Calls::CallInitiator do
  it "creates a new call with the appropriate data" do
    cached_twilio_caller_id = ENV["TWILIO_CALLER_ID"]
    ENV["TWILIO_CALLER_ID"] = "+15555551212"

    call_creator = double("calls", create: nil)
    initiator = Calls::CallInitiator.new("555-555-1234", call_creator)

    initiator.run

    call_data = {
      from: "+15555551212",
      to: "555-555-1234",
    }
    expect(call_creator).to have_received(:create).with(call_data)

    ENV["TWILIO_CALLER_ID"] = cached_twilio_caller_id
  end
end