#Opsicle, an OpsWorks CLI
A gem bringing the glory of OpsWorks to your command line.

[![Gem Version](https://badge.fury.io/rb/opsicle.png)](http://badge.fury.io/rb/opsicle)
[![Build Status](https://travis-ci.org/sportngin/opsicle.png?branch=master)](https://travis-ci.org/sportngin/opsicle)

## Installation
Add this line to your project's Gemfile:

```ruby
gem 'opsicle'
```

### Set up an Application to use opsicle

```yaml
# your_app_root/.opsicle

staging:
  stack_id: opsworks-stack-id
  app_id: opsworks-app-id
production:
  stack_id: opsworks-stack-id
  app_id: opsworks-app-id
```

```yaml
# ~/.fog

staging:
  aws_access_key_id: YOUR_AWS_ACCESS_KEY
  aws_secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
production:
  aws_access_key_id: YOUR_AWS_ACCESS_KEY
  aws_secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
  mfa_serial_number: YOUR_MFA_ID
```

## Using Opsicle

Run `opsicle help` for a full list of commands and their uses.  
Some common commands:

### Deployments
```bash

# Run a basic deploy for the current app
opsicle deploy staging

# Run the deploy for production
opsicle deploy production

```
By default, deploying opens the Opsicle Stack Monitor.
You may also use `--browser` to open the OpsWorks deployments screen instead,
or `--no-monitor` to ignore both monitoring options

### SSH
```bash
# SSH to a server instance in the given environment stack
opsicle ssh staging

# Set your user SSH key (PUBLIC KEY) for OpsWorks
opsicle ssh-key staging <key-file>

```

### Stack Monitor
```bash
# Launch the Opsicle Stack Monitor for the given environment stack
opsicle monitor staging

```
### Updating Custom Chef Recipes
```bash
 # Upload a cookbooks directory to S3 and update the stack's custom cookbooks
 opsicle chef-update staging --bucket-name my-opsworks-cookbooks
 
```
This command accepts a --path argument to the directory of cookbooks to upload. It defaults to 'cookbooks'.
It also accepts a --bucket-name for the base s3 bucket. This flag is required.
 

Opsicle accepts a `--verbose` flag or the VERBOSE environment variable to show additional information as commands are run.

Opsicle accepts a DEBUG environment variable to show additional logging such as stack traces for failed commands.
