require 'cgi'

class Reader
  attr_reader :name, :url, :title, :image

  def initialize config
    @name = config['name']
    @url = config['url']
    @title = config['title']
    @image = config['image']
    @encode = config['encode']
    @add_url = config['add_url']
  end

  def add_url url
    url = CGI.escape url unless @encode.zero?
    sprintf @add_url, url
  end
end

class ReaderManager
  class << self
    def config
      @config ||= YAML.load_file settings.root + '/config/readers.yml'
    end

    def load
      config.map do |c|
        Reader.new c
      end
    end
  end
end
