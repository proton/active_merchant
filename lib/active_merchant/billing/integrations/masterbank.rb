module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Masterbank
        autoload :Return, 'active_merchant/billing/integrations/masterbank/return.rb'
        autoload :Helper, 'active_merchant/billing/integrations/masterbank/helper.rb'
        autoload :Notification, 'active_merchant/billing/integrations/masterbank/notification.rb'
       
        mattr_accessor :service_url
        self.service_url = 'https://pay.masterbank.ru/acquiring'
        self.notification_confirmation_url = 'https://pay.masterbank.ru/acquiring/close'

        mattr_accessor :secret_key

        def self.helper(order, account, options = {})
          Helper.new(order, account, options)
        end

        def self.notification(post, options = {})
          Notification.new(post, options)
        end

        def self.return(query_string, options = {})
          Return.new(query_string)
        end
      end
    end
  end
end
