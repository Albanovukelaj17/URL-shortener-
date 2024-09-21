require 'sinatra'
require 'securerandom'
require 'yaml'
require 'uri'
require 'rqrcode'

class URLShortener
  def initialize
    @url_data = load_urls || {}
  end

  def shorten_url(long_url)
    # Percent-encode the long URL to handle non-ASCII characters
    encoded_url = URI.encode_www_form_component(long_url)
    short_code = SecureRandom.alphanumeric(6)
    @url_data[short_code] = encoded_url
    save_urls
    puts "Shortened URL saved: #{short_code} => #{encoded_url}"  # Debug
    short_code
  end

  def retrieve_url(short_code)
    encoded_url = @url_data[short_code]
    # Decode the percent-encoded URL when retrieving it
    long_url = URI.decode_www_form_component(encoded_url)
    puts "Retrieving URL for short code #{short_code}: #{long_url}"  # Debug
    long_url
  end

  def generate_url_code(url)
    qrcode = RQRCode::QRCode.new(url)  # Correct QR code generation
    qrcode.as_svg(module_size: 6)
  end

  private  # Mache die Hilfsmethoden "private"

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
  short_code = URI.encode_www_form_component(shortener.shorten_url(long_url))  # Encode the short code
  puts "Returning Short URL: http://localhost:4567/#{short_code}"  # Debug
  "Short URL: http://localhost:4567/#{short_code}"
end

# Route to handle redirection from short URL
get '/:short_code' do
  short_code = URI.decode_www_form_component(params[:short_code])  # Decode the short code
  puts "Requested short code: #{short_code}"  # Debug
  long_url = shortener.retrieve_url(short_code)

  if long_url
    # Encode the long URL before redirecting to avoid the ASCII error
    encoded_redirect_url = URI.encode(long_url)
    puts "Redirecting to #{encoded_redirect_url}"  # Debug
    redirect encoded_redirect_url
  else
    "Short URL not found!"
  end
end

# Route to generate QR code for a short URL
get '/qr/:short_code' do
  short_code = params[:short_code]
  short_url = "http://localhost:4567/#{short_code}"

  content_type 'image/svg+xml'
  shortener.generate_url_code(short_url)
end
