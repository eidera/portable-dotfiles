#! /usr/bin/env ruby

require 'pp'
require 'optparse'
require 'uri'

def get_dictionary_urls(encoded_word)
  results = []

  results << 'mkdictionaries:///?text=' + encoded_word
  #results << 'ldoce://' + encoded_word

  results
end

def get_website_urls(encoded_word)
  results = []

  results << 'https://www.google.co.jp/search?tbm=isch&q=' + encoded_word
  results << 'https://www.google.com/search?tbm=isch&q=%E8%AA%9E%E5%91%82%E5%90%88%E3%82%8F%E3%81%9B+' + encoded_word # 語呂合わせ+<検索ワード>
  #results << 'https://stock.adobe.com/jp/search?k=' + encoded_word
  #results << 'https://twitter.com/search?src=typed_query&q=%23ejb19%20' + encoded_word

  results
end

def print_usage()
  $stderr.printf("Usage: #{$0} [options] word\n")
  $stderr.printf("  -h, --help : Show Help\n")
  $stderr.printf("  -a         : All\n")
  $stderr.printf("  -d         : Dictionaries\n")
  $stderr.printf("  -w         : Web sites\n")
end

params = ARGV.getopts('hadw', 'help')

if (params['h'] || params['help'])
  print_usage
  exit 1
end

if ARGV.length < 1
  print_usage
  exit 1
end

#word = $stdin.read.split("\n")[0]
word = ARGV[0]
encoded_word = URI.escape(word)

is_dictionary = params['d'] || params['a']
is_website    = params['w'] || params['a']

unless is_dictionary || is_website
  is_dictionary = true
  is_website    = true
end

urls = []
urls += get_dictionary_urls(encoded_word) if is_dictionary
urls += get_website_urls(encoded_word) if is_website

urls.each do |url|
  run = sprintf("open '%s'", url)
  system(run)
end
