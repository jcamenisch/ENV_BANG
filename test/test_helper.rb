require 'simplecov'
require 'coveralls'

require 'minitest/spec'
require 'minitest/pride'
require 'minitest/autorun'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'env_bang'
