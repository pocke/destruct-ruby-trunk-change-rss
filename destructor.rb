require 'nokogiri'

class Destructor
  def self.destruct(rss)
    self.new(rss).destruct
  end

  def initialize(rss)
    @rss = rss
  end

  def destruct
    RSS::Maker.make("2.0") do |maker|
      maker.channel.title = rss.channel.title
      maker.channel.description = rss.channel.description
      maker.channel.link = rss.channel.link

      maker.items.do_sort = true

      rss.channel.items.each do |item|
        doc = Nokogiri::HTML(item.description)
        doc.css('div.section').each.with_index do |section, index|
          title = section.css('h1, h2, h3, h4, h5, h6').text
          description = section.css('p').text

          maker.items.new_item do |new_item|
            new_item.link = item.link
            new_item.date = item.date + index
            new_item.title = title
            new_item.description = description
          end
        end
      end
    end
  end

  attr_reader :rss
  private :rss
end
