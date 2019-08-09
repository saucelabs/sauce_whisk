# Major Version 0
## Minor Version 0.2
### 0.2.2
* Fixed require in `lib\sauce-whisk` to refer to the correct file; Thanks @anthony-chu!

### 0.2.1
* Added US_EAST option for headless
* Changed preferred value from US_VDC to US_WEST. US_VDC wil continue to work.
* @juandelgado added tunnel_identifier to Tunnels endpoint, closing #59; Thanks!

### 0.2.0
* Added the ability to select between US & EU VDC
* Made US VDC the default endpoint
* Added Deprecation warning for using the default endpoint instead of specifying it

## Minor Version 0.1
### 0.1.0
* Update REST_CLIENT and JSON libraries to allow them to place nicer with Ruby 2.4.x

### 0.0.22
* Looser version requirements (thanks @jeremy)

### 0.0.21
* Jobs.fetch will now _actually_ not swallow RestClient errors
* Gem should be faster to install; Test files are no longer included which means no waiting to download fixtures.

### 0.0.20
* ArgumentError will now be thrown if the gem can't find a Username or Access Key
* Jobs.fetch no longer swallows RestClient errors _unless_ specifically caused by a job not being finished.

### 0.0.19
* You can now configure SauceWhisk.username and SauceWhisk.access_key.  These values override all other configuration settings
* Removed Content-Type header from PUT commands as per documentation

### 0.0.18
* @tommeier is a champion and bumped rest_client to 1.8.0 to avoid a security flaw (Fixes #42).

### 0.0.17
* Added `asset_fetch_retries=` and `rest_retries=` methods to `SauceWhisk` object.  These are used in preference to any other configuration value.

### 0.0.16
* Don't try using 'puts' for the logger

### 0.0.15
* Allowed for use of the HTTP_PROXY environment variable for uh, configuring proxies
* Added 'saucewhisk' and 'sauce-whisk' require files

### 0.0.14
* Added `fetch!` to fail when jobs don't fetch assets
* Made `fetch` succeed in all cases
* Added retries for all 404s
* Added `delete` for assets (Thanks, @dmfranko!)

### 0.0.13
* Sauce storage support added (Thanks @bootstraponline)
* Various gem build quality fixes (Thanks @bootstraponline)
* Added `Jobs.delete_job` (Thanks, @seanknox!)

### 0.0.12
* Added additional minute types

### 0.0.8
* Correctly read Sauce Config

### 0.0.6
* Correct RestClient -- Actually require it

### 0.0.5
* Added Sauce class

### 0.0.4
* Added configuration loading from the Sauce gem, if present
