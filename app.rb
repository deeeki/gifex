$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
Bundler.require(:default) if defined?(Bundler)

require 'lib/simple_opml'
require 'lib/reader'

not_found do
  slim :not_found
end

get '/' do
  @q = ''
  slim :index
end

get '/search' do
  q = params[:q]
  redirect '/' if q.to_s.empty?
  redirect '/' + q
end

get '/*/export' do |u|
  @u = Temple::Utils::escape_html u
  @followings = Octokit.following(@u)
  halt 404 if @followings.empty?
  opml = SimpleOPML.new("GitHub #{@u}'s followings")
  @followings.each do |f|
    opml.add("https://github.com/#{f.login}", "https://github.com/#{f.login}.atom", "#{f.login}'s Activity")
  end
  content_type 'application/xml'
  attachment "github_#{@u}_followings_#{Date.today.strftime('%Y%m%d')}.xml"
  opml.to_s
end

get '/*' do |u|
  @u = Temple::Utils::escape_html u
  @followings = Octokit.following(@u)
  halt 404 if @followings.empty?
  @readers = ReaderManager.load
  slim :user
end
