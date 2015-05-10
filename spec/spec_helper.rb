$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'her/webmock'
require 'her/webmock/model'

require "her"

RSpec.configure do |config|
  config.after do
    WebMock.reset!
  end
end

Her::API.setup url: "http://api.example.com/" do |c|
  c.use Her::Middleware::DefaultParseJSON

  c.use Faraday::Adapter::NetHttp
end

class ClassicParentModel
  include Her::Model
  extend Her::WebMock::Model
end

class ClassicModel
  include Her::Model
  extend Her::WebMock::Model

  belongs_to :classic_parent_model

  include_root_in_json true
  parse_root_in_json true, format: :active_model_serializers
end
