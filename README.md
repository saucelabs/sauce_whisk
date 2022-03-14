# SauceWhisk

SauceWhisk provides an "ActiveRecord" style client for the [Sauce Labs](http://www.saucelabs.com) RESTful API.  If you're not using the [Sauce Gem](https://rubygems.org/gems/sauce) and you want a nice way to interact with our API, give this a try.

[![Gem Version](https://badge.fury.io/rb/sauce_whisk.svg)](http://badge.fury.io/rb/sauce_whisk)
[![Build Status](https://travis-ci.org/saucelabs/sauce_whisk.svg?branch=v0.0.12)](https://travis-ci.org/saucelabs/sauce_whisk)
[![Dependency Status](https://gemnasium.com/saucelabs/sauce_whisk.svg)](https://gemnasium.com/saucelabs/sauce_whisk)

## Installation

Add this line to your application's Gemfile:

    gem 'sauce_whisk', 'Some Version Here'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sauce_whisk

We recommend setting a hard version for now, as the gem is still kinda beta-y.

## Configuration

You'll need a [Sauce Labs account](http://www.saucelabs.com/signup).  They're free to try and, if you're an open source project, [your access is always free](http://saucelabs.com/opensauce).

## Data Center
As Sauce Labs now has two data centers, you'll need to select the DC your account is located in.

Choose `:EU_VDC` for the European Data Center.
Choose `:US_WEST` for the US West Coast Data Center.
Choose `:US_EAST` for the US East Coast Data Center (currently only in use with Headless).
Choose `:APAC` for the Australian Data Center.

Read more about the data center options [here](https://wiki.saucelabs.com/display/DOCS/Accessing+the+API).

### Values
| Value | ENV Variable | Meaning |
|-------|--------------|---------|
|:username | SAUCE_USERNAME | Your Sauce Labs Username |
|:access\_key | SAUCE\_ACCESS\_KEY| Your Access Key, found on the lower left of your Account page (Not your password!) |
|:asset\_fetch\_retries | SAUCE\_ASSET\_FETCH\_RETRY | Number of times to retry fetching assets | 
|:rest_retries | SAUCE_REST_RETRIES | Number of times to try failing REST calls |
|:data_center | SAUCE_DATA_CENTER | Which Data Center to access |


### Locations
There are four ways to configure SauceWhisk.  The gem tries each of the following locations in turn.  Note, Environment Variables are the preferred means of setting configuration.

#### Directly on the SauceWhisk object
`username`, `access_key`, `asset_fetch_retries`, `rest_retries` and `data_center` can be set directly on the SauceWhisk object:
```ruby
SauceWhisk.username = 'some_rad_tester'
SauceWhisk.asset_fetch_retries = 5
```

#### The Sauce gem
If you have the Sauce gem required, the SauceWhisk gem will try to read its configuration from the Sauce gem's configuration.

NB: The Sauce gem is deprecated. We recommend using different configuration techniques.

#### ondemand.yml
If you have an ondemand.yml, the SauceWhisk gem will try to read its configuration from that file.  The locations the gem looks for a ondemand.yml are, in order:

1. `./ondemand.yml` (The current directory)
2. `./config/ondemand.yml` (The config directory under the current directory)
3. `$GEM_LOCATION/../ondemand.yml` (The directory of the file which includes `sauce_whisk`
4. `~/.sauce/ondemand.yml` (The .sauce directory in the user's home directory)

The keys are the same as those in the 'value' table, above.

#### Environment variables
This is the preferred way.  Environment variable are available to all applications that need them, won't get accidentally checked into a repo and don't need to be edited for each team member.

```bash
SAUCE_USERNAME=Your Sauce Username
SAUCE_ACCESS_KEY=Your Access Key, found on the lower left of your Account page
```

### HTTP Proxies
To configure a proxy, set the 'HTTP_PROXY' or 'http_proxy' environment variable.  Proxies need to be a valid URI; HTTP Authentication can be included.

## Support
For support, please visit [The Sauce Labs Community Hub](https://community.saucelabs.com)

## Usage

### Marking jobs passed or failed
```ruby
    SauceWhisk::Jobs.pass_job job_id
    SauceWhisk::Jobs.fail_job job_id
    SauceWhisk::Jobs.change_status job_id, true_for_passed_false_for_failed
```

### Creating Job Objects

There are three ways to create a Job object.

```ruby
# Create an 'empty' job (i.e. don't retrieve job details from the API)
empty_job = SauceWhisk::Job.new job_id

# Create a job with details fetched from the API
fully_detailed_job = SauceWhisk::Jobs.fetch job_id

# Create a job with details fetched from the API, failing if the job is incomplete
partially_detailed_job = SauceWhisk::Jobs.fetch! job_id
```

Use the first form when you just want a simple way to push details to the API.  Use the second form when you want to fetch details from the API, but aren't overly fussy about having complete job information.  Use the third form to throw a `SauceWhisk::JobNotComplete` exception when fetching an incomplete job.  Jobs that are fetched incomplete will not have screenshots, and may not have videos or logs.

NB: It's not possible to create a new job on Sauce Labs' infrastructure with the API.

### Updating Job Metadata

#### Updating Pass or Fail Status
See [here](#marking-jobs-passed-or-failed)

#### Changing job names
```ruby
job = SauceWhisk::Jobs.fetch job_id
job.name = "Determine if the User can Invite Friends"

job.save
```

#### All possible changes

```ruby
job = SauceWhisk::Jobs.fetch job_id
job.build = "12.3.04-beta"
job.visibility = "public"
job.tags = "new_user"
job.name = "Determine if the User can Invite Friends"
job.custom_data = {:executor => "jparth", :team_city_config => "standard_with_instrumentation"}
job.passed = false

job.save
```

It is not possible to alter any other job properties.

### Other Job Properties

```ruby
job = SauceWhisk::Jobs.fetch job_id
job.id      # Sauce job_id
job.owner   # Account name of job's owner
job.browser # Browser job ran on
job.browser_verion  # Version of Browser
job.os      # OS job ran on
job.log_url # URL for accessing Job Log
job.creation_time   # When the job was first created
job.start_time      # When the job started running
job.end_time        # When the job finished
job.video_url       # URL for accessing screencast video
job.screenshot_urls # Array of URLs for accessing screenshots
job.has_all_asset_names?  # True if all asset names were fetched (eg job was complete)
```

### Deleting Jobs
```ruby
Jobs.delete_job job_id
```

### Assets

There are three types of asset for Sauce Labs jobs: screenshots, video and logs.  Assets are represented as an Asset object, which include the name, asset type and data.

#### Screenshots

```ruby
  job = SauceWhisk::Jobs.fetch job_id
  screenshots = job.screenshots # An array of Screenshot assets
```

#### Video

```ruby
  job = SauceWhisk::Jobs.fetch job_id
  video = job.video # A single Asset, holding the video
```

#### Deleting Assets

```ruby
SauceWhisk::Assets.delete job_id #==> Deletes all assets for job.
```

### Accounts

At the moment, it is only possible to query existing accounts, and create subaccounts.

#### Retrieving a specific account
```ruby
my_account = SauceWhisk::Accounts.fetch "account_name" # Returns a SauceWhisk::Account object, with its concurrency limit
my_account = SauceWhisk::Accounts.fetch("account_name", false) # Returns a SauceWhisk::Account object, does not fetch its concurrency limit
```

`SauceWhisk::Account` objects store data about the relevant account:

```ruby
my_account.username             # Sauce Labs Username
my_account.access_key           # Sauce Labs Access Key (For automated test authentication... Not your password)
my_account.minutes              # Automated minutes available for Windows, Android, Linux
my_account.manual_minutes       # Manual minutes available for Windows, Android, Linux
my_account.mac_minutes          # Automated minutes available for Mac, iOS
my_account.mac_manual_minutes   # Manual minutes available for Mac, iOS
my_account.total_concurrency    # Number of concurrent jobs allowed
my_account.mac_concurrency      # Number of concurrent Mac hosted jobs allowed (includes iPad, iPhone, Mac)
```

NB: Minutes counts can be strings

#### Retrieving the concurrency limits for an account

If you exceed your concurrency limits, your tests will be queued waiting for a free VM.  This may cause erroneous failures in your test cases, and no-one wants that.
```ruby
concurrencies = SauceWhisk::Accounts.concurrency_for "account_name"    # Hash containing both concurrency limits
mac_concurrency = SauceWhisk::Accounts.concurrency_for "account_name", :mac    # Fixnum of just the Mac limit
total_concurrency = SauceWhisk::Accounts.concurrency_for "account_name", :total    # Fixnum of the upper concurrency limit
```

#### Creating subaccounts

```ruby
parent = SauceWhisk::Accounts.fetch "account_name"

subaccount = parent.add_subaccount("User", "Username", "User@email.com", "Password") # New SauceWhisk::SubAccount
```

SubAccounts are a subclass of Account, with an accessor for their parent object.
```ruby
subaccount.parent == parent #=>true
```

### Tunnels

Tunnels give information about currently running [Sauce Connect](https://saucelabs.com/docs/connect) tunnels for a given user.

#### Fetching All Active Tunnels

```ruby
all_tunnels = SauceWhisk::Tunnels.all   # An array of SauceWhisk::Tunnel objects
all_tunnels_as_json = SauceWhisk::Tunnels.all(:fetch_each => false)  # An array of Tunnel IDs
```

#### Details for a specific tunnel
```ruby
tunnel = SauceWhisk::Tunnels.fetch(tunnel_id)   # An instance of Tunnel
tunnel.id        # The Tunnel, um, id.
tunnel.owner     # The Sauce Account responsible for the tunnel -- The Credentials used to open it
tunnel.status    # Whether or not the tunnel is open
tunnel.host      # The Sauce Labs machine hosting the other end of the Tunnel
tunnel.creation_time  # When the tunnel was opened, in Epoch time
```

#### Stopping a Tunnel

```ruby
tunnel = SauceWhisk::Tunnels.fetch tunnel_id
tunnel.stop  # Stops the Tunnel

SauceWhisk::Tunnels.stop tunnel_id   # Stops the tunnel with the given id
```
### Retrying fetching of assets
Occasionally, assets won't be available immediately after the job is finished.  The gem will automatically retry fetching them.

You can configure how many times the gem retries by configuring 'asset\_fetch\_retries` to your desired number of retries.

### Generic Sauce Labs Information

The Sauce class returns non-user-specific info about available platforms, the number of jobs run, and the status of Sauce Labs' infrastructure.

These can be used without authentication.

#### Fetch All Available Platforms

You can obtain an Array of all available webdriver platforms using `SauceWhisk::Sauce.platforms`:

```ruby
platforms = SauceWhisk::Sauce.platforms        # Fetch all platforms or return cached values
platforms = SauceWhisk::Sauce.platforms(true)  # Force a fetch of all platforms

platforms.first # => A Hash of platform details:

 {
    "long_name"=>"Firefox",             # Full name of the platform's browser
    "api_name"=>"firefox",              # desired_capabilities name of the platform
    "long_version"=>"20.0.1.",          # Full version number for the platform's browser
    "preferred_version"=>"",            # Preferred version of the platform's browser (If none is requested)
    "automation_backend"=>"webdriver",  # Whether this is a Webdriver or Selenium-rc driven platform
    "os"=>"Linux",                      # desired_capabilities name of the Platform's Operating System
    "short_version"=>"20"               # desired_capabilities name of the Platform's Browsers's version
 }
```

The most important values for a platform are the **os**, **api_name**, **short_version** fields.  These are the values to use for desired_capabilites *os*, *browser* and *browser_version* respectively.

The gem does not support retrieval of selenium-rc platforms at the current time

#### Count

```ruby
all_tests = SauceWhisk::Sauce.total_job_count  # The total number of jobs ever run with Sauce Labs' help
```

#### Service Status

```ruby
status = SauceWhisk::Sauce.service_status   # Check the status of Sauce Labs' service

status.inspect # =>

{
  :wait_time=>0.39880952380952384,                          # Delay between requesting a job and it starting
  :service_operational=>true,                               # Operational Status -- Boolean
  :status_message=>"Basic service status checks passed."    # More info when erros occuring
}
```

### Logger

You can set a custom logger object, passing anything that responds to puts:

```ruby
SauceWhisk.logger = my_logger
```

SauceWhisk.logger defaults to STDOUT, at the warn level.

### Storage

Create a new [storage object](http://saucelabs.com/docs/rest#storage):

```ruby
storage = SauceWhisk::Storage.new username: 'my_user_name', key: '00', debug: true
```

If the environment variables SAUCE_USERNAME and SAUCE_ACCESS_KEY are set then:

```ruby
storage = SauceWhisk::Storage.new debug: true
```

List all files in storage.

```ruby
storage.files
```

Upload a file.

```ruby
storage.upload '/tmp/sauce/test.zip'
```

## Troubleshooting
### SSL Problems
#### SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (RestClient::SSLCertificateNotVerified)

This error is often thrown when you are missing certs.  Many thanks to Greg Sypolt who discovered that one possibe cause is:

_Ruby 2.2.1 comes packaged with a bad cert since OpenSSL is deprecated in Apple. It doesn't get updated by default with homebrew. This link https://github.com/google/google-api-ruby-client/issues/253 shows you how to fix the SSL issue for 2.2.1 and by moving to 2.2.3 it suppose to be fixed. I upgraded my local and Jenkins to use Ruby 2.2.3 and OpenSSL issues no longer exists._

## Contributing

1. Fork the [sauce-labs version](https://github.com/saucelabs/sauce_whisk) of this repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/saucelabs/sauce_whisk/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
