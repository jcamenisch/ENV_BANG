require_relative 'test_helper'

describe ENV_BANG do
  it "Raises exception if unconfigured ENV var requested" do
    ENV['UNCONFIGURED'] = 'unconfigured'
    proc { ENV!['UNCONFIGURED'] }.must_raise KeyError
  end

  it "Raises exception if configured ENV var is not present" do
    ENV.delete('NOT_PRESENT')

    proc {
      ENV!.config do
        use 'NOT_PRESENT'
      end
    }.must_raise KeyError
  end

  it "Includes provided description in error message" do
    ENV.delete('NOT_PRESENT')

    e = proc {
      ENV!.config do
        use 'NOT_PRESENT', 'You need a NOT_PRESENT var in your ENV'
      end
    }.must_raise(KeyError)
    e.message.must_include 'You need a NOT_PRESENT var in your ENV'
  end

  it "Uses provided default value if ENV var not already present" do
    ENV.delete('WASNT_PRESENT')

    ENV!.config do
      use 'WASNT_PRESENT', default: 'a default value'
    end
    ENV!['WASNT_PRESENT'].must_equal 'a default value'
  end

  it "Returns actual value from ENV if present" do
    ENV['PRESENT'] = 'present in environment'

    ENV!.config do
      use 'PRESENT', default: "You won't need this."
    end
    ENV!['PRESENT'].must_equal 'present in environment'
  end
end
