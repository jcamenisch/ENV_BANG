require 'simplecov'

SimpleCov.start do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter,
    ])
  end

  add_filter %w[version.rb env_bang-rails.rb]
end

require 'minitest/autorun'
require 'minitest/spec'
require 'env_bang'
