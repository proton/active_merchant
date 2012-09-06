require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Masterbank
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def self.recognizes?(params)
            params.has_key?('RRN') && params.has_key?('INT_REF')
          end

          def complete?
            status == '0'
          end

          def amount
            BigDecimal.new(gross)
          end

          def item_id
            params['ORDER']
          end

          def transaction_id
            params['RRN']
          end

          def currency
            params['CURRENCY']
          end

          #0 - ok, 1 - an attempt to re-pay, 2 - rejected, 3 - technical problems
          def status
            params['RESULT']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['AMOUNT']
          end

          def internal_code
            params['INT_REF']
          end

          def response_content_type
            'text/plain'
          end
            
          def generate_md5string(timestamp)
          end
          
          def generate_md5check(timestamp)
            Digest::MD5.hexdigest(generate_md5string(timestamp))
          end

          def post_data(action, parameters = {})
            post = {}

            %w[AMOUNT ORDER RRN INT_REF TERMINAL].each do |key|
              post[key] = params[key]
            end

            timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
            post['TIMESTAMP'] = timestamp
            md5string = params['TERMINAL'].to_s+timestamp.to_s+params['ORDER'].to_s+params['AMOUNT'].to_s+Masterbank.secret_key.to_s
            post['SIGN'] = Digest::MD5.hexdigest(md5string)

            request = post.merge(parameters).collect { |key, value| "x_#{key}=#{CGI.escape(value.to_s)}" }.join("&")
            request
          end
          
          def acknowledge
            payload =  post_data
            response = ssl_post(Masterbank.notification_confirmation_url, payload)
            puts 'test'
            puts response.inspect
            response
          end

          def success_response(*args)
            "OK"
          end

          def error_response(error_type, options = {})
            "ERROR"
          end
          
        end
      end
    end
  end
end
