require 'sinatra'
require 'securerandom'

class URLShortener
  def initialize
    @url_data = {}
  end

  def shorten_url(long_url)
    short_code = SecureRandom.alphanumeric(6)
    @url_data[short_code] = long_url
    short_code
  end

  def retrieve_url(short_code)
    @url_data[short_code]
  end
end

shortener = URLShortener.new

# Route to shorten a URL
post '/shorten' do
  long_url = params[:url]
  short_code = shortener.shorten_url(long_url)
  "Short URL: http://localhost:4567/#{short_code}"
end

# Route to handle redirection from short URL
get '/:short_code' do
  short_code = params[:short_code]
  long_url = shortener.retrieve_url(short_code)

  if long_url
    redirect long_url
  else
    "Short URL not found!"
  end
end
