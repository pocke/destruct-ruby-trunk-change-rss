require 'sinatra'
require 'rss'
require 'open-uri'
require_relative './destructor'

ORIGIN_URL = 'https://ruby-trunk-changes.hatenablog.com/rss'

configure do
  mime_type :rss, 'application/rss+xml; charset=UTF-8'
end

get '/rss' do
  content_type :rss
  content = open(ORIGIN_URL) { |io| io.read }
  orig_rss = RSS::Parser.parse(content)
  Destructor.destruct(orig_rss).to_s
end
