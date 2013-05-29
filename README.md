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
    
### Marking jobs passed or failed
```ruby
    SauceWhisk::Jobs.pass_job job_id
    SauceWhisk::Jobs.fail_job job_id
```    
    
### Creating Job Objects

There are two ways to create a Job object.  

```ruby
# Create an 'empty' job (i.e. don't retrieve job details from the API)
empty_job = Job.new job_id

# Create a job with details fetched from the API
fully_detailed_job = Jobs.fetch job_id
```

Use the first form when you just want a simple way to push details to the API.  Use the last form when you want to fetch details from the API.

NB: It's not possible to create a new job on Sauce Labs' infrastructure with the API.

### Updating Job Metadata

```ruby
job = Job.new job_id
job.build = "12.3.04-beta"
job.visibility = "public"
job.tags = "new_user"
job.name = "Determine if the User can Invite Friends"
job.custom_data = {:executor => "jparth", :team_city_config => "standard_with_instrumentation"}
job.passed = false

job.save
```

It is not possible to alter any other job properties.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
