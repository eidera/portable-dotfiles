#! /usr/bin/env ruby

class AsinExtractor
    def initialize(contents)
        @contents = contents
    end

    def execute()
      extract_validity_elements(@contents.map {|x| get_asins_from_url(x.strip)})
    end

    protected

    def get_asins_from_url(url)
      return [] unless amazon_url?(url)

      asins = get_asins_from_search_url(url)
      return asins unless asins.empty?

      return get_asins_from_product_url(url)
    end

    def amazon_url?(content)
      /http.*amazon(.co)?.jp/ =~ content
    end

    def get_asins_from_search_url(url)
      return [] unless /hidden-keywords=/ =~ url
      url.gsub(/^.*hidden-keywords=/, '').split('|')
    end

    def get_asins_from_product_url(url)
      url.sub(/\?.*$/, '').split('/').each do |el|
        next unless /^\w{10}$/ =~ el
        return [el]
      end
      []
    end

    def extract_validity_elements(asins)
      asins.flatten.delete_if{|x| x.nil?}.uniq
    end
end

class AmazonUrlMaker
    #URL_PREFIX = 'https://amazon.jp' # 一部の商品でエラーになるようだ
    URL_PREFIX = 'https://www.amazon.co.jp'

    def initialize(asins)
      @asins = asins
    end

    def multiple_products?()
      @asins.length > 1
    end

    def get_search_url()
      URL_PREFIX + '/s?hidden-keywords=' + @asins.join('|')
    end

    def get_product_urls()
      @asins.map{|x| get_product_url(x)}
    end

    protected

    def get_product_url(asin)
        return URL_PREFIX + '/dp/' + asin
    end
end

extractor = AsinExtractor.new(STDIN.readlines)
url_maker = AmazonUrlMaker.new(extractor.execute())
printf("%s\n", url_maker.get_search_url()) if url_maker.multiple_products?
printf("%s\n", url_maker.get_product_urls().join("\n"))
