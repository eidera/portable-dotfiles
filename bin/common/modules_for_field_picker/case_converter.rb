#! /usr/bin/env ruby

module CaseConverter
  class << self
    def to_lowercase(str)
      str.downcase
    end

    def to_UPPERCASE(str)
      str.upcase
    end

    def to_PascalCase(str)
      # Convert to snake_case first, then transform to PascalCase
      normalize_to_snake_case(str)
        .split('_')
        .map(&:capitalize)
        .join
    end

    def to_camelCase(str)
      # Convert to snake_case first, then transform to camelCase
      words = normalize_to_snake_case(str).split('_')
      words[0] + words[1..].map(&:capitalize).join
    end

    def to_kebab_case(str)
      normalize_to_snake_case(str).tr('_', '-')
    end

    def to_snake_case(str)
      normalize_to_snake_case(str)
    end

    private

    def normalize_to_snake_case(str)
      str
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')  # URLEncoder -> URL_Encoder
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')      # fooBar -> foo_Bar
        .tr('-', '_')                           # foo-bar -> foo_bar
        .downcase                               # foo_Bar -> foo_bar
    end
  end
end


def get_item(str, title)
  sprintf("%s\t%s", title, str)
end

def output(items)
  items.each do |item|
    printf("%s\n", item)
  end
end

########################
# main処理開始

if ARGV.length != 1
  $stderr.printf("#{$0} {word}\n")
  exit(1)
end

input = ARGV[0]

sources = [
  get_item(CaseConverter.to_camelCase(input), 'camelCase'),
  get_item(CaseConverter.to_PascalCase(input), 'PascalCase'),
  get_item(CaseConverter.to_snake_case(input), 'snake_case'),
  get_item(CaseConverter.to_kebab_case(input), 'kebab-case'),
  get_item(CaseConverter.to_lowercase(input), 'lowercase'),
  get_item(CaseConverter.to_UPPERCASE(input), 'UPPERCASE'),
]
output(sources)

# vim: set ft=ruby fdm=marker ts=2 sw=2 ro :
