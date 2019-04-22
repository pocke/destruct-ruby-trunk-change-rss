require 'sinatra'
require 'rss'
require 'open-uri'
require 'cgi'
require_relative './destructor'

configure do
  mime_type :rss, 'application/rss+xml; charset=UTF-8'
end

get '/rss' do
  mode = params[:mode]&.to_sym
  unless mode
    status 400
    return "mode param is required"
  end

  origin_url = params[:origin_url]&.then { |url| CGI.unescape(url) }
  unless origin_url
    status 400
    return 'origin_url param is required'
  end

  content_type :rss

  content = open(origin_url) { |io| io.read }
  orig_rss = RSS::Parser.parse(content)
  Destructor.destruct(orig_rss, mode: mode).to_s
end
