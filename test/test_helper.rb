require 'simplecov'
require 'coveralls'

require 'minitest/autorun'
require 'minitest/spec'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'env_bang'
