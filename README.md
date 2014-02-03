[![Gem Version](https://badge.fury.io/rb/env_bang.png)](https://rubygems.org/gems/env_bang)
[![Build Status](https://secure.travis-ci.org/jcamenisch/ENV_BANG.png?branch=master)](https://travis-ci.org/jcamenisch/ENV_BANG)
[![Dependency Status](https://gemnasium.com/jcamenisch/ENV_BANG.png)](https://gemnasium.com/jcamenisch/ENV_BANG)
[![Code Climate](https://codeclimate.com/github/jcamenisch/ENV_BANG.png)](https://codeclimate.com/github/jcamenisch/ENV_BANG)
[![Coverage Status](https://coveralls.io/repos/jcamenisch/ENV_BANG/badge.png?branch=master)](https://coveralls.io/r/jcamenisch/ENV_BANG)

# ENV! 

Do a bang-up job managing your environment variables.

ENV! provides a thin wrapper around ENV to accomplish a few things:

- Provide a central place to specify all your app’s environment variables.
- Fail loudly and helpfully if any environment variables are missing.
- Prevent an application from starting up with missing environment variables.
  (This is especially helpful in environments like Heroku, as your app will
  continue running the old code until the server is configured for a new revision.)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'env_bang'
```

Or for Rails apps, use `env_bang-rails` instead for more convenience:

```ruby
gem 'env_bang-rails'
```

And then execute:

```sh
$ bundle
```

## Usage

### Basic Configuration

First, configure your environment variables somewhere in your app’s
startup process. If you use the env_bang-rails gem, place this in `config/env.rb`
to load before application configuration.

Example configuration:

```ruby
ENV!.config do
  use :APP_HOST
  use :RAILS_SECRET_TOKEN
  use :STRIPE_SECRET_KEY
  use :STRIPE_PUBLISHABLE_KEY
  # ... etc.
end
```

Once a variable is specified with the `use` method, access it with

```ruby
ENV!['MY_VAR']
```

This will function just like accessing `ENV` directly, except that it will require the variable
to have been specified, and be present in the current environment. If either of these conditions
is not met, a KeyError will be raised with an explanation of what needs to be configured.

### Adding a default value

For some variables, you’ll want to include a default value in your code, and allow each
environment to ommit the variable for default behavios. You can accomplish this with the
`:default` option:

```ruby
ENV!.config do
  # ...
  use :MAIL_DELIVERY_METHOD, default: 'smtp'
  # ...
end
```

### Adding a description

When a new team member installs or deploys your project, they may run into a missing
environment variable error. Save them time by including documentation along with the error
that is raised. To accomplish this, provide a description (of any length) to the `use` method:

```ruby
ENV!.config do
  use 'RAILS_SECRET_KEY_BASE',
      'Generate a fresh one with `SecureRandom.urlsafe_base64(64)`; see http://guides.rubyonrails.org/security.html#session-storage'
end
```

Now if someone installs or deploys the app without setting the RAILS_SECRET_KEY_BASE variable,
they will see these instructions immediately upon running the app.

### Automatic type conversion

ENV! can convert your environment variables for you, keeping that tedium out of your application
code. To specify a type, use the `:class` option:

```ruby
ENV!.config do
  use :COPYRIGHT_YEAR,       class: Integer
  use :MEMCACHED_SERVERS,    class: Array
  use :MAIL_DELIVERY_METHOD, class: Symbol, default: :smtp
  use :DEFAULT_FRACTION,     class: Float
  use :ENABLE_SOUNDTRACK,    class: :boolean
end
```

Note that arrays will be derived by splitting the value on commas (','). To get arrays
of a specific type of value, use the `:of` option:

```ruby
ENV!.config do
  use :YEARS_OF_INTEREST, class: Array, of: Integer
end
```

#### Default type conversion behavior

If you don’t specify a `:class` option for a variable, ENV! defaults to a special
type conversion called `:StringUnlessFalsey`. This conversion returns a string, unless
the value is a "falsey" string ('false', 'no', 'off', '0', 'disable', or 'disabled').
To turn off this magic for one variable, pass in `class: String`. To disable it globally,
set

```ruby
ENV!.config do
  default_class String
end
```

#### Custom type conversion

Suppose your app needs a special type conversion that doesn’t come with ENV_BANG. You can
implement the conversion yourself with the `add_class` method in the `ENV!.config` block.
For example, to convert one of your environment variables to type `Set`, you could write
the following configuration:

```sh
# In your environment:
export NUMBER_SET=1,3,5,7,9
```

```ruby
# In your env.rb configuration file:
require 'set'

ENV!.config do
  add_class Set do |value, options|
    Set.new self.Array(value, options || {})
  end

  use :NUMBER_SET, class: Set, of: Integer
end
```

```ruby
# Somewhere in your application:
ENV!['NUMBER_SET']
#=> #<Set: {1, 3, 5, 7, 9}>
```

## Implementation Notes

1. ENV! is simply a method that returns ENV_BANG. In certain contexts
   (like defining a class), the exclamation mark notation is not allowed,
   so we use an alias to get this shorthand.

2. Any method that can be run within an `ENV!.config` block can also be run
   as a method directly on `ENV!`. For instance, instead of

   ```ruby
   ENV!.config do
      add_class Set do
        ...
      end

      use :NUMBER_SET, class: Set
   end
   ```

   It would also work to run

   ```ruby
   ENV!.add_class Set do
      ...
   end

   ENV!.use :NUMBER_SET, class: Set
   ```
   
   While the `config` block is designed to provide a cleaner configuration
   file, calling the methods directly can occasionally be handy, such as when
   trying things out in an IRB/Pry session.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
