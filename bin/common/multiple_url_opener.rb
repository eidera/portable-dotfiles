#! /usr/bin/env ruby

require 'pp'
require 'uri'

# 特殊対応のフィルター
def filter(url)
  url.sub(/\)$/, '') # Markdown のURLリンク表記内の最後の `)` を削除する
end

data = $stdin.read
urls = URI.extract(data).map{|x| filter(x)}

urls.each do |url|
  run = sprintf("open '%s'", url)
  system(run)
end

puts data
