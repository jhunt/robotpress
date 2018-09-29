require 'json'

class VCAP
  class << self
    def service(tagged)
      vcap = JSON.parse(ENV['VCAP_SERVICES'] || '{}')
      vcap.each do |name, services|
        services.each do |service|
          service['tags'].each do |tag|
            if tag == tagged
              return service['credentials']
            end
          end
        end
      end

      nil
    end
  end
end
