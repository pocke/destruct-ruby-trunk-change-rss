require 'nokogiri'

class Destructor
  def self.destruct(rss, mode:)
    self.new(rss, mode: mode).destruct
  end

  def initialize(rss, mode:)
    @rss = rss
    @mode = mode
  end

  def destruct
    RSS::Maker.make("2.0") do |maker|
      maker.channel.title = rss.channel.title
      maker.channel.description = rss.channel.description
      maker.channel.link = rss.channel.link

      maker.items.do_sort = true

      rss.channel.items.each do |item|
        case mode
        when :header
          destruct_header(maker, item)
        when :hr
          destruct_hr(maker, item)
        end
      end
    end
  end

  def destruct_header(maker, item)
    doc = Nokogiri::HTML(item.description)
    doc.css('div.section').each.with_index do |section, index|
      title = section.css('h1, h2, h3, h4, h5, h6').text
      description = section.css('p').text
      make_new_item(
        maker: maker,
        link: item.link,
        date: item.date + index,
        title: title,
        description: description,
      )
    end
  end

  def destruct_hr(maker, item)
    doc = Nokogiri::HTML(item.description)
    buf = +""
    index = 0
    doc.traverse do |node|
      case
      when node.text?
        buf << node.text
      when node.name == "hr"
        make_new_item(
          maker: maker,
          link: item.link,
          date: item.date + index,
          title: '--',
          description: buf,
        )

        buf = +""
        index += 1
      end
    end

    if buf =~ /\S/
      make_new_item(
        maker: maker,
        link: item.link,
        date: item.date + index,
        title: '--',
        description: buf,
      )
    end
  end

  def make_new_item(maker:, link:, date:, title:, description:)
    maker.items.new_item do |new_item|
      new_item.link = link
      new_item.date = date
      new_item.title = title
      new_item.description = description
    end
  end

  attr_reader :rss, :mode
  private :rss, :mode
end
