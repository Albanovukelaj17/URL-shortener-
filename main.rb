require 'sinatra'
require 'securerandom'
require 'yaml'
require 'uri'

class URLShortener
  def initialize
    @url_data = load_urls || {}
  end

  def shorten_url(long_url)
    encoded_url = URI.encode(long_url)  # Encode the long URL here
    short_code = SecureRandom.alphanumeric(6)
    @url_data[short_code] = encoded_url  # Store the encoded long URL
    save_urls
    puts "Shortened URL saved: #{short_code} => #{encoded_url}"  # Debug
    short_code
  end

  def retrieve_url(short_code)
    encoded_url = @url_data[short_code]
    long_url = URI.decode(encoded_url)  # Decode the long URL when retrieving
    puts "Retrieving URL for short code #{short_code}: #{long_url}"  # Debug
    long_url
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
  puts "Returning Short URL: http://localhost:4567/#{short_code}"  # Debug
  "Short URL: http://localhost:4567/#{short_code}"
end

# Route to handle redirection from short URL
get '/:short_code' do
  short_code = URI.decode(params[:short_code])  # Decode the short code
  puts "Requested short code: #{short_code}"  # Debug
  long_url = shortener.retrieve_url(short_code)

  if long_url
    puts "Redirecting to #{long_url}"  # Debug
    redirect long_url
  else
    "Short URL not found!"
  end
end
