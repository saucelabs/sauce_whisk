# SauceWhisk

SauceWhisk provides an "ActiveRecord" style client for the [Sauce Labs](http://www.saucelabs.com) RESTful API.  If you're not using the [Sauce Gem](https://rubygems.org/gems/sauce) and you want a nice way to interact with our API, give this a try.

[![Build Status](https://travis-ci.org/DylanLacey/sauce_whisk.png)](https://travis-ci.org/DylanLacey/sauce_whisk)

## Installation

Add this line to your application's Gemfile:

    gem 'sauce_whisk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sauce_whisk

## Configuration

You'll need a [Sauce Labs account](http://wwww.saucelabs.com/signup).  They're free to try and, if you're an open source project, [your access is always free](http://saucelabs.com/opensauce).

Once you've got your account, set the following environment variables:

```bash
SAUCE_USERNAME=Your Sauce Username
SAUCE_ACCESS_KEY=Your Access Key, found on the lower left of your Account page
```

## Usage
    
### Marking a Job as Passed

    SauceWhisk::Jobs.pass_job job_id
    
### Marking a Job as Failed
   
    SauceWhisk::Jobs.fail_job job_id

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
