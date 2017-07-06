require_relative 'test_helper'

describe ENV_BANG do
  before do
    ENV_BANG.instance_eval { @vars = nil }
    ENV_BANG::Classes.default_class = nil
  end

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

  it "Raises exception immediately if value is invalid for the required type" do
    proc {
      ENV['NOT_A_DATE'] = '2017-02-30'
      ENV!.use 'NOT_A_DATE', class: Date
    }.must_raise ArgumentError

    proc {
      ENV!.use 'NOT_A_DATE_DEFAULT', class: Date, default: '2017-02-31'
    }.must_raise ArgumentError
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

  describe "Type casting" do
    let(:truthy_values) { %w[true on yes yo yup anything] }
    let(:falsey_values) { %w[false no off disable disabled 0] << '' }
    let(:integers) { %w[0 1 10 -42 -55] }
    let(:floats) { %w[0.1 1.3 10 -42.3 -55] }

    it "Casts Integers" do
      integer = integers.sample
      ENV['INTEGER'] = integer
      ENV!.use 'INTEGER', class: Integer

      ENV!['INTEGER'].must_equal integer.to_i
    end

    it "Casts Symbols" do
      ENV['SYMBOL'] = 'symbol'
      ENV!.use 'SYMBOL', class: Symbol

      ENV!['SYMBOL'].must_equal :symbol
    end

    it "Casts Floats" do
      float = floats.sample
      ENV['FLOAT'] = float
      ENV!.use 'FLOAT', class: Float

      ENV!['FLOAT'].must_equal float.to_f
      ENV!['FLOAT'].class.must_equal Float
    end

    it "Casts Arrays" do
      ENV['ARRAY'] = 'one,two , three, four'
      ENV!.use 'ARRAY', class: Array

      ENV!['ARRAY'].must_equal %w[one two three four]
    end

    it "Casts Arrays of Integers" do
      ENV['INTEGERS'] = integers.join(',')
      ENV!.use 'INTEGERS', class: Array, of: Integer

      ENV!['INTEGERS'].must_equal integers.map(&:to_i)
    end

    it "Casts Arrays of Floats" do
      ENV['FLOATS'] = floats.join(',')
      ENV!.use 'FLOATS', class: Array, of: Float

      ENV!['FLOATS'].must_equal floats.map(&:to_f)
    end

    it "regression: Casting Array always returns Array" do
      ENV['ARRAY'] = 'one,two , three, four'
      ENV!.use 'ARRAY', class: Array

      2.times do
        ENV!['ARRAY'].must_equal %w[one two three four]
      end
    end

    it "Casts Hashes" do
      ENV['HASH'] = 'one: two, three: http://four.com'
      ENV!.use 'HASH', class: Hash

      ENV!['HASH'].must_equal({one: 'two', three: 'http://four.com'})
    end

    it 'Casts Hashes of Integers' do
      ENV['INT_HASH'] = 'one: 111, two: 222'
      ENV!.use 'INT_HASH', class: Hash, of: Integer

      ENV!['INT_HASH'].must_equal({one: 111, two: 222})
    end

    it 'Casts Hashes with String keys' do
      ENV['STRKEY_HASH'] = 'one: two, three: four'
      ENV!.use 'STRKEY_HASH', class: Hash, keys: String

      ENV!['STRKEY_HASH'].must_equal({'one' => 'two', 'three' => 'four'})
    end

    it 'Casts Hashes with alternate separators' do
      ENV['ALT_HASH'] = 'one:two = three; four,five=six'
      ENV!.use 'ALT_HASH', class: Hash, sep: ';', val_sep: '='

      ENV!['ALT_HASH'].must_equal({:'one:two' => 'three', :'four,five' => 'six'})
    end

    it "Casts true" do
      ENV['TRUE'] = truthy_values.sample
      ENV!.use 'TRUE', class: :boolean

      ENV!['TRUE'].must_equal true
    end

    it "Casts false" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: :boolean

      ENV!['FALSE'].must_equal false
    end

    it "converts falsey or empty string to false by default" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE'

      ENV!['FALSE'].must_equal false
    end

    it "leaves falsey string as string if specified" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: String

      ENV!['FALSE'].class.must_equal String
    end

    it "casts Dates" do
      ENV['A_DATE'] = '2005-05-05'
      ENV!.use 'A_DATE', class: Date

      ENV!['A_DATE'].class.must_equal Date
      ENV!['A_DATE'].must_equal Date.new(2005, 5, 5)
    end

    it "casts DateTimes" do
      ENV['A_DATETIME'] = '2005-05-05 5:05pm'
      ENV!.use 'A_DATETIME', class: DateTime

      ENV!['A_DATETIME'].class.must_equal DateTime
      ENV!['A_DATETIME'].must_equal DateTime.new(2005, 5, 5, 17, 5)
    end

    it "casts Times" do
      ENV['A_TIME'] = '2005-05-05 5:05pm'
      ENV!.use 'A_TIME', class: Time

      ENV!['A_TIME'].class.must_equal Time
      ENV!['A_TIME'].must_equal Time.new(2005, 5, 5, 17, 5)
    end

    it "casts Regexps" do
      # Escaping backslashes is not without its pitfalls. Developer beware.
      ENV['A_REGEX'] = '^(this|is|a|[^tes.*\|]t.\.\*/\\\)$'
      ENV!.use 'A_REGEX', class: Regexp

      ENV!['A_REGEX'].class.must_equal Regexp
      ENV!['A_REGEX'].must_equal(/^(this|is|a|[^tes.*\|]t.\.\*\/\\)$/)
    end

    it "allows default class to be overridden" do
      ENV!.default_class.must_equal :StringUnlessFalsey
      ENV!.config { default_class String }
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: String

      ENV!['FALSE'].class.must_equal String
    end

    it "allows addition of custom types" do
      require 'set'

      ENV['NUMBER_SET'] = '1,3,5,7,9'
      ENV!.config do
        add_class Set do |value, options|
          Set.new self.Array(value, options || {})
        end

        use :NUMBER_SET, class: Set, of: Integer
      end

      ENV!['NUMBER_SET'].must_equal Set.new [1, 3, 5, 7, 9]
    end

    describe "Kernel casting delegators" do
      it "casts Integers" do
        ENV['A_INTEGER'] = '-123'
        ENV!.use 'A_INTEGER', class: Integer

        ENV!['A_INTEGER'].must_equal(-123)
      end

      it "casts Floats" do
        ENV['A_FLOAT'] = '123.456'
        ENV!.use 'A_FLOAT', class: Float

        ENV!['A_FLOAT'].must_equal 123.456
      end

      it "casts Strings" do
        ENV['A_STRING'] = 'What do I write here?'
        ENV!.use 'A_STRING', class: String
        ENV!['A_STRING'].must_equal 'What do I write here?'
      end

      it "casts Rationals" do
        ENV['A_RATIONAL'] = '3/32'
        ENV!.use 'A_RATIONAL', class: Rational

        ENV!['A_RATIONAL'].class.must_equal Rational
        ENV!['A_RATIONAL'].must_equal 3.to_r/32
        ENV!['A_RATIONAL'].to_s.must_equal '3/32'
      end

      it "casts Complexes" do
        ENV['A_COMPLEX'] = '123+4i'
        ENV!.use 'A_COMPLEX', class: Complex

        ENV!['A_COMPLEX'].class.must_equal Complex
        ENV!['A_COMPLEX'].to_s.must_equal '123+4i'
      end

      it "casts Pathnames" do
        ENV['A_PATHNAME'] = '~/.git/config'
        ENV!.use 'A_PATHNAME', class: Pathname

        ENV!['A_PATHNAME'].class.must_equal Pathname
        ENV!['A_PATHNAME'].to_s.must_equal '~/.git/config'
      end

      it "casts URIs" do
        ENV['A_URI'] = 'http://www.example.com/path/to/nowhere'
        ENV!.use 'A_URI', class: URI

        ENV!['A_URI'].class.must_equal URI::HTTP
        ENV!['A_URI'].to_s.must_equal 'http://www.example.com/path/to/nowhere'
      end
    end
  end

  describe "Hash-like behavior" do
    it "provides configured keys" do
      ENV['VAR1'] = 'something'
      ENV['VAR2'] = 'something else'
      ENV!.use 'VAR1'
      ENV!.use 'VAR2'

      ENV!.keys.must_equal %w[VAR1 VAR2]
    end

    it "provides configured values" do
      ENV['VAR1'] = 'something'
      ENV['VAR2'] = 'something else'
      ENV!.use 'VAR1'
      ENV!.use 'VAR2'

      ENV!.values.must_equal %w[something something\ else]
    end
  end

  describe "Formatting" do
    it "Includes provided description in error message" do
      ENV.delete('NOT_PRESENT')

      e = proc {
        ENV!.config do
          use 'NOT_PRESENT', 'You need a NOT_PRESENT var in your ENV'
        end
      }.must_raise(KeyError)
      e.message.must_include 'You need a NOT_PRESENT var in your ENV'
    end

    it "Removes indentation from provided descriptions" do
      ENV.delete('NOT_PRESENT')

      e = proc {
        ENV!.config do
          use 'NOT_PRESENT', <<-DESC
            This multiline description
              has a lot of indentation
                varying from line to line
            like so
          DESC
        end
      }.must_raise(KeyError)
      e.message.must_include <<-UNINDENTED
    This multiline description
      has a lot of indentation
        varying from line to line
    like so
      UNINDENTED
    end
  end
end
