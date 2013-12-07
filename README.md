[![Gem Version](https://badge.fury.io/rb/env_bang.png)](https://rubygems.org/gems/env_bang)
[![Build Status](https://secure.travis-ci.org/jcamenisch/ENV_BANG.png?branch=master)](https://travis-ci.org/jcamenisch/ENV_BANG)
[![Dependency Status](https://gemnasium.com/jcamenisch/ENV_BANG.png)](https://gemnasium.com/jcamenisch/ENV_BANG)
[![Code Climate](https://codeclimate.com/github/jcamenisch/ENV_BANG.png)](https://codeclimate.com/github/jcamenisch/ENV_BANG)
[![Coverage Status](https://coveralls.io/repos/jcamenisch/ENV_BANG/badge.png?branch=master)](https://coveralls.io/r/jcamenisch/ENV_BANG)

# ENV! 

Do a bang-up job managing your environment variables.

ENV! provides a thin wrapper around ENV to accomplish a few things:

- Provide a central place to specify what environment variables you intend to use
- Fail loudly with an informative error message if environment variables are not
  properly configured.
- Prevent an application from starting up if a needed environment variable is not set.
  (This is especially helpful in environment like Heroku, as it prevents launch of a
  new version of your app if it depends on missing environment variables—a problem
  that might go unnoticed until your customers come across a 500 error.)

## Installation

Add this line to your application's Gemfile:

    gem 'env_bang'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install env_bang

## Usage

### Basic Configuration

First, configure your environment variables somewhere in your app’s
startup process. In a Rails app, this could live in `config/initializers/env.rb`.

```ruby
ENV!.config do
  use 'APP_HOST'
  use 'RAILS_SECRET_TOKEN'
  use 'STRIPE_SECRET_KEY'
  use 'STRIPE_PUBLISHABLE_KEY'
  # ... etc.
end
```

A single variable can also be configured with `ENV!.use MY_VAR`, but the `ENV!.config` block
will typically contain all the variables for your app.

Once a variable is specified with `ENV!.use`, you can access it with

```ruby
ENV!['MY_VAR']
```

This will function just like accessing the environment variable directly, except that it will
require the variable to be specified with `ENV!.use`, and present in the current environment.
If either of these conditions is not met, a KeyError will be raised with an explanation of
what needs to be configured.

### Adding a default value

In some cases, you don't need to require each environment to set a variable explicitly.
You might have a reasonable default value that can be overridden. You can specify a default
value with the `:default` option:

```ruby
ENV!.config do
  # ...
  use MAIL_DELIVERY_METHOD, default: :smtp
  # ...
end
```

### Adding a description

When a new team members installs or deploys your project, they may run into a missing
environment variable error. It can save them a great deal of time to include documentation
on the missing environment variable directly in the error that is raised. To accomplish this,
provide a description (of any length) to the `use` method:

```ruby
ENV!.config do
  use 'RAILS_SECRET_KEY_BASE',
      'Generate a fresh one with `SecureRandom.urlsafe_base64(64)`; see http://guides.rubyonrails.org/security.html#session-storage'
end
```

If someone installs or deploys the app and forgets to set the RAILS_SECRET_KEY_BASE variable in
their environment, they will see these instructions immediately upon running the app.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
