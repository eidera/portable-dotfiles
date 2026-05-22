#! /usr/bin/env ruby

require 'optparse'

DEFAULT_LENGTH = 15
DEFAULT_COUNT  = 10

class PasswordGenerator
  SYMBOLS = %w(! @ # $ % ^ & * - _ = + | ` ~ [ { ] } ; : ' " , < . > / ? ) + ['(', ')']
  NUMBERS        = [*0..9]
  SMALL_ALPHABETS = [*'a'..'z']
  LARGE_ALPHABETS = [*'A'..'Z']
  ALPHABETS = SMALL_ALPHABETS + LARGE_ALPHABETS

  def initialize(length, symbols = SYMBOLS)
    @length = length
    @number_flag   = set_numbers
    @alphabet_flag = set_alphabets
    @symbol_flag   = set_symbols
    @symbols = symbols
  end

  def numbers?
    @number_flag
  end

  def alphabets?
    @alphabet_flag
  end

  def symbols?
    @symbol_flag
  end

  def set_numbers
    @number_flag = true
  end

  def unset_numbers
    @number_flag = false
  end

  def set_alphabets
    @alphabet_flag = true
  end

  def unset_alphabets
    @alphabet_flag = false
  end

  def set_symbols
    @symbol_flag = true
  end

  def unset_symbols
    @symbol_flag = false
  end

  def execute
    seeds.sample(@length).join
  end

  protected

  def seeds
    result = []
    result += NUMBERS if numbers?
    result += ALPHABETS if alphabets?
    result += @symbols if symbols?
    result
  end
end

params = ARGV.getopts('hnasl:c:', 'help', 'symbols:!@#$%^&*-_=+|`~[{]};:\'",<.>/?()')

if (params['h'] || params['help'])
  $stderr.printf("Usage: #{$0} [options]\n")
  $stderr.printf("  -h, --help : Show Help\n")
  $stderr.printf("  -n : Number character Off\n")
  $stderr.printf("  -a : Alphabet character Off\n")
  $stderr.printf("  -s : Symbol character Off\n")
  $stderr.printf("  -l VAL : Password length\n")
  $stderr.printf("  -c VAL : Password counts\n")
  $stderr.printf("  --symbols VAL : Allow symbol character list\n")
  exit 1
end

length = params['l'].to_i
length = DEFAULT_LENGTH if(length <= 0)

counts = params['c'].to_i
counts = DEFAULT_COUNT if(counts <= 0)

symbols = params['symbols'].split('')

generator = PasswordGenerator.new(length, symbols)
params['n'] ? generator.unset_numbers   : generator.set_numbers
params['a'] ? generator.unset_alphabets : generator.set_alphabets
params['s'] ? generator.unset_symbols   : generator.set_symbols

puts counts.times.map { generator.execute }
