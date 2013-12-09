require 'simplecov'
require 'coveralls'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'env_bang'
