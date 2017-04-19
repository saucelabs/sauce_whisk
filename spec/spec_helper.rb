require "psych"
require "sauce_whisk"
require "webmock/rspec"
require "vcr"

puts "PSYCH: #{Psych::VERSION}"


VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    :erb => true,
    :record => :new_episodes
  }
  config.filter_sensitive_data("<SAUCE_USERNAME>") { ENV["SAUCE_USERNAME"] }
  config.filter_sensitive_data("<SAUCE_ACCESS_KEY>") { ENV["SAUCE_ACCESS_KEY"] }
end

RSpec.configure do |config|
  #config.treat_symbols_as_metadata_keys_with_true_values = true
end
