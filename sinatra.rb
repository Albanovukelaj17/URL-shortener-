require 'sinatra'
require 'securerandom'
require 'yaml'
require 'uri'  # Add URI to handle URL encoding/decoding

class URLShortener
  def initialize
    @url_data = load_urls || {}
  end

  def shorten_url(long_url)
    short_code = SecureRandom.alphanumeric(6)
    @url_data[short_code] = long_url
    save_urls
    short_code
  end

  def retrieve_url(short_code)
    @url_data[short_code]
  end

  private

  def load_urls
    YAML.load_file('urls.yml') if File.exist?('urls.yml')
  end

  def save_urls
    File.open('urls.yml', 'w') { |file| file.write(@url_data.to_yaml) }
  end
end

shortener = URLShortener.new

# Route to shorten a URL
post '/shorten' do
  long_url = params[:url]
  short_code = URI.encode(shortener.shorten_url(long_url))  # Encode the short code
  "Short URL: http://localhost:4567/#{short_code}"
end

# Route to handle redirection from short URL
get '/:short_code' do
  short_code = URI.decode(params[:short_code])  # Decode the short code
  long_url = shortener.retrieve_url(short_code)

  if long_url
    redirect long_url
  else
    "Short URL not found!"
  end
end
