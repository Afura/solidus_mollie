module SolidusMollie
   class MollieLogger
     def self.debug(message = nil)
       return unless message.present?
 
       @logger ||= Logger.new(File.join(Rails.root, 'log', 'solidus_mollie.log'))

      #  .datetime_format = "%Y-%m-%d %H:%M:%S"
       @logger.debug(message)
     end
 
     class << self
       attr_writer :logger
     end
   end
 end