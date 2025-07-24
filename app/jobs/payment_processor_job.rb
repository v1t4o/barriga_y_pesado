class PaymentProcessorJob < ApplicationJob

  def self.perform(data)
    PaymentProcessorService.send_payment(format_payload(data))
  end

  def self.format_payload(data)
    {
      "correlationId": data[:correlationId],
      "amount": data[:amount],
      "requestedAt" : Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')
    }
  end
end