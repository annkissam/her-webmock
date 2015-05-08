require 'spec_helper'

describe Her::WebMock do
  it 'has a version number' do
    expect(Her::WebMock::VERSION).not_to be nil
  end

  it 'has default configuration values' do
    expect(Her::WebMock.config.default_request_test_headers).to eq({})
  end
end
