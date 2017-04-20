# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sauce_whisk/version'

Gem::Specification.new do |gem|
  gem.name        = 'sauce_whisk'
  gem.version     = SauceWhisk::VERSION
  gem.authors     = ['Dylan Lacey']
  gem.email       = ['github@dylanlacey.com']
  gem.description = 'A Wrapper for the Sauce Labs REST API.'
  gem.summary     = "Sauce_Whisk lets you mix extra data into your Sauce test results!\nFetch and update Job details, screenshots, videos and logs."
  gem.homepage    = 'http://www.github.com/dylanlacey/sauce_whisk'

  gem.files         = `git ls-files`.split($/).reject { |e| /spec/.match e }
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.license = 'MIT'

  gem.add_runtime_dependency 'rest-client', '>= 2.0.1'
  gem.add_runtime_dependency 'json', '>= 2.1.0'
  gem.add_development_dependency 'vcr', '~> 2.9'
  gem.add_development_dependency 'webmock', '~> 1.21'
  gem.add_development_dependency 'rspec', '~> 3.3'
  gem.add_development_dependency 'rake', '>= 10.4'
end
