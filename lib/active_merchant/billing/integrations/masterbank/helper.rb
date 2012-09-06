module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Masterbank
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          def initialize(order, account, options = {})
            Masterbank.secret_key = options.delete(:secret)
            @payment_methods = options.delete(:payments)
            @account = account
            super
          end
          
          def form_fields
            @fields.merge(payment_method_fields)
          end
            
          def generate_md5string
            @account.to_s+fields[mappings[:timestamp]].to_s+fields[mappings[:order]].to_s+self.amount.to_s+Masterbank.secret_key.to_s
          end
          
          def generate_md5check
            Digest::MD5.hexdigest(generate_md5string)
          end
          
          def payment_method_fields
            fields = {}
            fields[mappings[:terminal]] = @account
            fields[mappings[:timestamp]] = Time.now.utc.strftime("%Y%m%d%H%M%S")
            fields[mappings[:sign]] = generate_md5check
            fields[mappings[:lang]] = 'rus'
            fields
          end

          mapping :amount, 'AMOUNT'
          mapping :order, 'ORDER'
          mapping :return_url, 'MERCH_URL'
          mapping :terminal, 'TERMINAL'
          mapping :timestamp, 'TIMESTAMP'
          mapping :sign, 'SIGN'    
          mapping :lang, 'LANGUAGE'
          mapping :currency, 'CURRENCY'
        end
      end
    end
  end
end