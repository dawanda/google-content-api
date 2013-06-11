require 'webmock/rspec'
require 'lib/google_content_api'

require ::File.expand_path("../lib/google_content_api", File.dirname(__FILE__))

RSpec.configure do |config|
  config.order = 'random'
end

def fake_token
 "foobarbaz"
end