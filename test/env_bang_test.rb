require_relative 'test_helper'

describe ENV_BANG do
  before do
    ENV_BANG.instance_eval { @vars = nil }
    ENV_BANG::Classes.default_class = nil
  end

  it "Raises exception if unconfigured ENV var requested" do
    ENV['UNCONFIGURED'] = 'unconfigured'
    _{ ENV!['UNCONFIGURED'] }.must_raise KeyError
  end

  it "Raises exception if configured ENV var is not present" do
    ENV.delete('NOT_PRESENT')

    _{
      ENV!.config do
        use 'NOT_PRESENT'
      end
    }.must_raise KeyError
  end

  it "Raises exception immediately if value is invalid for the required type" do
    _{
      ENV['NOT_A_DATE'] = '2017-02-30'
      ENV!.use 'NOT_A_DATE', class: Date
    }.must_raise ArgumentError

    _{
      ENV!.use 'NOT_A_DATE_DEFAULT', class: Date, default: '2017-02-31'
    }.must_raise ArgumentError
  end

  it "Uses provided default value if ENV var not already present" do
    ENV.delete('WASNT_PRESENT')

    ENV!.config do
      use 'WASNT_PRESENT', default: 'a default value'
    end
    _(ENV!['WASNT_PRESENT']).must_equal 'a default value'
  end

  it "Returns actual value from ENV if present" do
    ENV['PRESENT'] = 'present in environment'

    ENV!.config do
      use 'PRESENT', default: "You won't need this."
    end
    _(ENV!['PRESENT']).must_equal 'present in environment'
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

      _(ENV!['INTEGER']).must_equal integer.to_i
    end

    it "Casts Symbols" do
      ENV['SYMBOL'] = 'symbol'
      ENV!.use 'SYMBOL', class: Symbol

      _(ENV!['SYMBOL']).must_equal :symbol
    end

    it "Casts Floats" do
      float = floats.sample
      ENV['FLOAT'] = float
      ENV!.use 'FLOAT', class: Float

      _(ENV!['FLOAT']).must_equal float.to_f
      _(ENV!['FLOAT'].class).must_equal Float
    end

    it "Casts Arrays" do
      ENV['ARRAY'] = 'one,two , three, four'
      ENV!.use 'ARRAY', class: Array

      _(ENV!['ARRAY']).must_equal %w[one two three four]
    end

    it "Casts Arrays of Integers" do
      ENV['INTEGERS'] = integers.join(',')
      ENV!.use 'INTEGERS', class: Array, of: Integer

      _(ENV!['INTEGERS']).must_equal integers.map(&:to_i)
    end

    it "Casts Arrays of Floats" do
      ENV['FLOATS'] = floats.join(',')
      ENV!.use 'FLOATS', class: Array, of: Float

      _(ENV!['FLOATS']).must_equal floats.map(&:to_f)
    end

    it "regression: Casting Array always returns Array" do
      ENV['ARRAY'] = 'one,two , three, four'
      ENV!.use 'ARRAY', class: Array

      2.times do
        _(ENV!['ARRAY']).must_equal %w[one two three four]
      end
    end

    it "Casts Hashes" do
      ENV['HASH'] = 'one: two, three: http://four.com'
      ENV!.use 'HASH', class: Hash

      _(ENV!['HASH']).must_equal({one: 'two', three: 'http://four.com'})
    end

    it 'Casts Hashes of Integers' do
      ENV['INT_HASH'] = 'one: 111, two: 222'
      ENV!.use 'INT_HASH', class: Hash, of: Integer

      _(ENV!['INT_HASH']).must_equal({one: 111, two: 222})
    end

    it 'Casts Hashes with String keys' do
      ENV['STRKEY_HASH'] = 'one: two, three: four'
      ENV!.use 'STRKEY_HASH', class: Hash, keys: String

      _(ENV!['STRKEY_HASH']).must_equal({'one' => 'two', 'three' => 'four'})
    end

    it 'Casts Hashes with alternate separators' do
      ENV['ALT_HASH'] = 'one:two = three; four,five=six'
      ENV!.use 'ALT_HASH', class: Hash, sep: ';', val_sep: '='

      _(ENV!['ALT_HASH']).must_equal({:'one:two' => 'three', :'four,five' => 'six'})
    end

    it "Casts true" do
      ENV['TRUE'] = truthy_values.sample
      ENV!.use 'TRUE', class: :boolean

      _(ENV!['TRUE']).must_equal true
    end

    it "Casts false" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: :boolean

      _(ENV!['FALSE']).must_equal false
    end

    it "converts falsey or empty string to false by default" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE'

      _(ENV!['FALSE']).must_equal false
    end

    it "leaves falsey string as string if specified" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: String

      _(ENV!['FALSE'].class).must_equal String
    end

    it "casts Dates" do
      ENV['A_DATE'] = '2005-05-05'
      ENV!.use 'A_DATE', class: Date

      _(ENV!['A_DATE'].class).must_equal Date
      _(ENV!['A_DATE']).must_equal Date.new(2005, 5, 5)
    end

    it "casts DateTimes" do
      ENV['A_DATETIME'] = '2005-05-05 5:05pm'
      ENV!.use 'A_DATETIME', class: DateTime

      _(ENV!['A_DATETIME'].class).must_equal DateTime
      _(ENV!['A_DATETIME']).must_equal DateTime.new(2005, 5, 5, 17, 5)
    end

    it "casts Times" do
      ENV['A_TIME'] = '2005-05-05 5:05pm'
      ENV!.use 'A_TIME', class: Time

      _(ENV!['A_TIME'].class).must_equal Time
      _(ENV!['A_TIME']).must_equal Time.new(2005, 5, 5, 17, 5)
    end

    it "casts Regexps" do
      # Escaping backslashes is not without its pitfalls. Developer beware.
      ENV['A_REGEX'] = '^(this|is|a|[^tes.*\|]t.\.\*/\\\)$'
      ENV!.use 'A_REGEX', class: Regexp

      _(ENV!['A_REGEX'].class).must_equal Regexp
      _(ENV!['A_REGEX']).must_equal(/^(this|is|a|[^tes.*\|]t.\.\*\/\\)$/)
    end

    it "casts inclusive Ranges of Integers by default" do
      ENV['A_RANGE'] = '1..100'
      ENV!.use 'A_RANGE', class: Range

      _(ENV!['A_RANGE'].class).must_equal Range
      _(ENV!['A_RANGE']).must_equal 1..100
    end

    it "casts exclusive Ranges as directed" do
      ENV['EXCLUSIVE_RANGE'] = '1..100'
      ENV!.use 'EXCLUSIVE_RANGE', class: Range, exclusive: true

      _(ENV!['EXCLUSIVE_RANGE']).must_equal 1...100

      ENV['ANOTHER_EXCLUSIVE_RANGE'] = '1...100'
      ENV!.use 'ANOTHER_EXCLUSIVE_RANGE', class: Range, exclusive: true

      _(ENV!['ANOTHER_EXCLUSIVE_RANGE']).must_equal 1...100
    end

    it "casts Ranges of floats" do
      ENV['FLOAT_RANGE'] = '1.5..100.7'
      ENV!.use 'FLOAT_RANGE', class: Range, of: Float

      _(ENV!['FLOAT_RANGE']).must_equal 1.5..100.7
    end

    it "casts Ranges of strings" do
      ENV['FLOAT_RANGE'] = 'az..za'
      ENV!.use 'FLOAT_RANGE', class: Range, of: String

      _(ENV!['FLOAT_RANGE']).must_equal 'az'..'za'
    end

    it "allows default class to be overridden" do
      _(ENV!.default_class).must_equal :StringUnlessFalsey
      ENV!.config { default_class String }
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: String

      _(ENV!['FALSE'].class).must_equal String
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

      _(ENV!['NUMBER_SET']).must_equal Set.new [1, 3, 5, 7, 9]
    end

    describe "Kernel casting delegators" do
      it "casts Integers" do
        ENV['A_INTEGER'] = '-123'
        ENV!.use 'A_INTEGER', class: Integer

        _(ENV!['A_INTEGER']).must_equal(-123)
      end

      it "casts Floats" do
        ENV['A_FLOAT'] = '123.456'
        ENV!.use 'A_FLOAT', class: Float

        _(ENV!['A_FLOAT']).must_equal 123.456
      end

      it "casts Strings" do
        ENV['A_STRING'] = 'What do I write here?'
        ENV!.use 'A_STRING', class: String
        _(ENV!['A_STRING']).must_equal 'What do I write here?'
      end

      it "casts Rationals" do
        ENV['A_RATIONAL'] = '3/32'
        ENV!.use 'A_RATIONAL', class: Rational

        _(ENV!['A_RATIONAL'].class).must_equal Rational
        _(ENV!['A_RATIONAL']).must_equal 3.to_r/32
        _(ENV!['A_RATIONAL'].to_s).must_equal '3/32'
      end

      it "casts Complexes" do
        ENV['A_COMPLEX'] = '123+4i'
        ENV!.use 'A_COMPLEX', class: Complex

        _(ENV!['A_COMPLEX'].class).must_equal Complex
        _(ENV!['A_COMPLEX'].to_s).must_equal '123+4i'
      end

      it "casts Pathnames" do
        ENV['A_PATHNAME'] = '~/.git/config'
        ENV!.use 'A_PATHNAME', class: Pathname

        _(ENV!['A_PATHNAME'].class).must_equal Pathname
        _(ENV!['A_PATHNAME'].to_s).must_equal '~/.git/config'
      end

      it "casts URIs" do
        ENV['A_URI'] = 'http://www.example.com/path/to/nowhere'
        ENV!.use 'A_URI', class: URI

        _(ENV!['A_URI'].class).must_equal URI::HTTP
        _(ENV!['A_URI'].to_s).must_equal 'http://www.example.com/path/to/nowhere'
      end
    end
  end

  describe "Hash-like behavior" do
    it "provides configured keys" do
      ENV['VAR1'] = 'something'
      ENV['VAR2'] = 'something else'
      ENV!.use 'VAR1'
      ENV!.use 'VAR2'

      _(ENV!.keys).must_equal %w[VAR1 VAR2]
    end

    it "provides configured values" do
      ENV['VAR1'] = 'something'
      ENV['VAR2'] = 'something else'
      ENV!.use 'VAR1'
      ENV!.use 'VAR2'

      _(ENV!.values).must_equal %w[something something\ else]
    end
  end

  describe "Formatting" do
    it "Includes provided description in error message" do
      ENV.delete('NOT_PRESENT')

      e = _{
        ENV!.config do
          use 'NOT_PRESENT', 'You need a NOT_PRESENT var in your ENV'
        end
      }.must_raise(KeyError)
      _(e.message).must_include 'You need a NOT_PRESENT var in your ENV'
    end

    it "Removes indentation from provided descriptions" do
      ENV.delete('NOT_PRESENT')

      e = _{
        ENV!.config do
          use 'NOT_PRESENT', <<-DESC
            This multiline description
              has a lot of indentation
                varying from line to line
            like so
          DESC
        end
      }.must_raise(KeyError)
      _(e.message).must_include <<-UNINDENTED
    This multiline description
      has a lot of indentation
        varying from line to line
    like so
      UNINDENTED
    end
  end

  describe "Enumerable methods" do
    before do
      ENV['ONE'] = '1'
      ENV['A'] = 'A'
      ENV['INT_HASH'] = 'one: 1, two: 2'
      ENV['FLOAT'] = '1.234'

      ENV!.config do
        use 'ONE', class: Integer
        use 'A', class: String
        use 'INT_HASH', class: Hash, of: Integer
        use 'FLOAT', class: Float
      end
    end

    it "converts keys and parsed values to a Hash" do
      _(ENV!.to_h).must_equal({
        'ONE'      => 1,
        'A'        => 'A',
        'INT_HASH' => { one: 1, two: 2 },
        'FLOAT'    => 1.234,
      })
    end

    it "Doesn't allow write access via the hash (It's not a reference to internal values)" do
      h = ENV!.to_h
      h['A'] = 'changed'
      _(ENV!['A']).must_equal 'A'
    end

    it "returns an Array representation of the hash too" do
      _(ENV!.to_a).must_equal [
        ['ONE', 1],
        ['A', 'A'],
        ['INT_HASH', { one: 1, two: 2 }],
        ['FLOAT', 1.234],
      ]
    end

    it "implements other Enumerable methods too" do
      _(ENV!.each.to_a).must_equal [
        ['ONE', 1],
        ['A', 'A'],
        ['INT_HASH', { one: 1, two: 2 }],
        ['FLOAT', 1.234],
      ]

      _(ENV!.to_enum.to_a).must_equal ENV!.to_a
    end
  end

  describe "Hash-like read methods" do
    before do
      ENV['ONE'] = '1'
      ENV['A'] = 'A'
      ENV['INT_HASH'] = 'one: 1, two: 2'
      ENV['FLOAT'] = '1.234'

      ENV!.config do
        use 'ONE', class: Integer
        use 'A', class: String
        use 'INT_HASH', class: Hash, of: Integer
        use 'FLOAT', class: Float
      end
    end

    it "implements .assoc and .rassoc correctly" do
      _(ENV!.assoc('ONE')).must_equal ['ONE', 1]
      _(ENV!.rassoc(1)).must_equal ['ONE', 1]
    end

    it "implements .each_key correctly" do
      _(ENV!.each_key.to_a).must_equal(%w[ONE A INT_HASH FLOAT])
      keys = []
      ENV!.each_key do |key|
        keys << key
      end
      _(keys).must_equal(%w[ONE A INT_HASH FLOAT])
    end

    it "implements .each_pair correctly" do
      _(ENV!.each_pair.to_a).must_equal(ENV!.to_a)
      pairs = []
      ENV!.each_pair do |pair|
        pairs << pair
      end
      _(pairs).must_equal(ENV!.to_a)
    end

    it "implements .each_value correctly" do
      _(ENV!.each_value.to_a).must_equal [1, 'A', { one: 1, two: 2 }, 1.234]
      values = []
      ENV!.each_value do |value|
        values << value
      end
      _(values).must_equal [1, 'A', { one: 1, two: 2 }, 1.234]
    end

    it "implements .empty? correctly" do
      _(ENV!.empty?).must_equal(false)
    end

    it "implements .except correctly" do
      _(ENV!.except('INT_HASH', 'FLOAT', 'NOTATHING')).must_equal({
        'ONE' => 1,
        'A'   => 'A',
      })
    end

    it "implements .fetch correctly" do
      _(ENV!.fetch('ONE')).must_equal 1
      _{
        ENV!.fetch('TWO')
      }.must_raise KeyError
      _(ENV!.fetch('TWO', 2)).must_equal 2
      _(ENV!.fetch('TWO') { 22 }).must_equal 22
    end

    it "implements .invert correctly" do
      _(ENV!.invert).must_equal({
        1 => 'ONE',
        'A' => 'A',
        { one: 1, two: 2 } => 'INT_HASH',
        1.234 => 'FLOAT',
      })
    end

    it "implements .key correctly" do
      _(ENV!.key(1)).must_equal 'ONE'
    end

    it "implements .key?/.has_key? correctly" do
      _(ENV!.key?('ONE')).must_equal true
      _(ENV!.has_key?('ONE')).must_equal true

      _(ENV!.key?('TWO')).must_equal false
      _(ENV!.has_key?('TWO')).must_equal false
    end

    it "implements .length correctly" do
      _(ENV!.length).must_equal 4
      _(ENV!.size).must_equal 4
    end

    it "implements .slice correctly" do
      _(ENV!.slice('INT_HASH', 'FLOAT', 'NOTATHING')).must_equal({
        'INT_HASH' => { one: 1, two: 2 },
        'FLOAT'    => 1.234,
      })
    end

    it "implements .to_hash correctly" do
      _(ENV!.to_hash).must_equal ENV!.to_h
    end

    it "implements .value?/has_value? correctly" do
      _(ENV!.value?(1)).must_equal true
      _(ENV!.value?(2)).must_equal false
      _(ENV!.has_value?(1)).must_equal true
      _(ENV!.has_value?(2)).must_equal false
    end

    it "implements .values_at correctly" do
      _(ENV!.values_at('INT_HASH', 'FLOAT', 'NOTATHING')).must_equal [
        { one: 1, two: 2 }, 1.234, nil
      ]
    end
  end
end
