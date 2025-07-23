class PaymentProcessorService
  PAYMENT_PROCESSOR_DEFAULT=ENV.fetch('PAYMENT_PROCESSOR_DEFAULT')
  PAYMENT_PROCESSOR_FALLBACK=ENV.fetch('PAYMENT_PROCESSOR_FALLBACK')

  def self.send_payment(payload)
    payment_processor_url = verify_payment_processor

    return false unless payment_processor_url

    conn = Faraday.new(url: payment_processor_url) do |builder|
      builder.request :json
      builder.response :json
      #builder.response :raise_error
      # builder.response :logger
    end

    begin
      response = conn.post('/payments', payload)
      true
    rescue Faraday::Error => e
      puts e.response[:status]
      puts e.response[:body]
      false
    end
  end

  def self.verify_payment_processor
    payment_default = verify_payment_processor_default

    return PAYMENT_PROCESSOR_DEFAULT unless payment_default&.failing

    payment_fallback = verify_payment_processor_fallback

    return PAYMENT_PROCESSOR_FALLBACK unless payment_fallback&.failing

    nil
  end

  private

  def self.verify_payment_processor_default
    Rails.cache.fetch('payment_processor_default_health', ttl: 5.seconds) do
      conn = Faraday.new(url: PAYMENT_PROCESSOR_DEFAULT) do |builder|
        builder.request :json
        builder.response :json
        #builder.response :raise_error
        #builder.response :logger
      end
  
      begin
        response = conn.get('/payments/service-health')
        return response.body
      rescue Faraday::Error => e
        puts e.response[:status]
        puts e.response[:body]
        return { failing: true, minResponseTime: 9999 }
      end
    end
  end

  def self.verify_payment_processor_fallback
    Rails.cache.fetch('payment_processor_fallback_health', ttl: 5.seconds) do
      conn = Faraday.new(url: PAYMENT_PROCESSOR_FALLBACK) do |builder|
        builder.request :json
        builder.response :json
        #builder.response :raise_error
        #builder.response :logger
      end
  
      begin
        response = conn.get('/payments/service-health')

        return response.body
      rescue Faraday::Error => e
        puts e.response[:status]
        puts e.response[:body]
        return { failing: true, minResponseTime: 9999 }
      end
    end
  end
end
