require "her/webmock/version"

module Her
  module WebMock
    class Configuration
      attr_accessor :default_request_test_headers

      def initialize(options = {})
        self.default_request_test_headers = {}
      end
    end

    def self.configure
      yield config
      config.freeze
    end

    def self.config
      @config ||= Configuration.new
    end
  end
end
