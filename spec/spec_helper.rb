require "sauce_whisk"
require "webmock/rspec"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    :erb => true,
    :record => :none
  }
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
