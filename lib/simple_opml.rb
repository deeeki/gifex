require 'cgi'
require 'time'
require 'nokogiri'
require 'open-uri'

# refs: http://route477.net/d/?date=20070612#p05
class SimpleOPML
  attr_reader :sites

  Site = Struct.new(:url, :rss, :title)

  def initialize(title)
    @title = title
    @sites = []
  end

  def add(url, rss, title=nil)
    title = get_title(rss) if title.nil?
    @sites << Site.new(url, rss, title)
  end

  def get_title(rss)
    doc = Nokogiri::XML(open(rss))
    if (title = doc % :title)
      title.inner_text
    else
      ""
    end
  end

  def to_s
    <<EOD
<?xml version="1.0" encoding="utf-8"?>
<opml version="1.0">
<head>
<title>#{CGI.escapeHTML @title}</title>
<dateCreated>#{Time.now.rfc822}</dateCreated>
<ownerName />
</head>
<body>
<outline text="#{CGI.escapeHTML @title}">
#{@sites.map{|s| site_to_outline(s)}.join("\n")}
</outline>
</body>
</opml>
EOD
  end

  def site_to_outline(site)
    %!<outline title="#{CGI.escapeHTML site.title}" htmlUrl="#{CGI.escapeHTML site.url}" text="#{CGI.escapeHTML site.title}" type="rss" xmlUrl="#{CGI.escapeHTML site.rss}" />!
  end

end
