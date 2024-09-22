require 'sinatra'
require 'securerandom'
require 'yaml'
require 'uri'
require 'rqrcode'
require 'time'

class URLShortener
  def initialize
    @url_data = load_urls || {}
  end

  def shorten_url(long_url)
    encoded_url = URI.encode_www_form_component(long_url)
    short_code = SecureRandom.alphanumeric(6)
    @url_data[short_code] = {
      'long_url' => encoded_url,
      'created_at' => Time.now,
      'last_access' => nil,
      'click_count' => 0
    }
    save_urls
    short_code
  end

  def retrieve_url(short_code)
    data = @url_data[short_code]
    if data
      data['last_accessed'] = Time.now
      data['click_count'] += 1
      save_urls
      URI.decode_www_form_component(data['long_url'])
    else
      nil
    end
  end

  def get_stats(short_code)
    @url_data[short_code]
  end

  def generate_url_code(url)
    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_svg(module_size: 6)
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

# Home route with HTML form
get '/' do
  <<-HTML
    <form action="/shorten" method="POST">
      <label for="url">Enter URL to shorten:</label>
      <input type="text" id="url" name="url" required><br><br>
      <label for="custom_code">Enter custom short code (optional):</label>
      <input type="text" id="custom_code" name="custom_code"><br><br>
      <button type="submit">Shorten URL</button>
    </form>
  HTML
end

# Route to shorten a URL
post '/shorten' do
  long_url = params[:url]
  custom_code = params[:custom_code].empty? ? nil : params[:custom_code]  

  begin
    short_code = shortener.shorten_url(long_url, custom_code)
    content_type 'text/html'
    status 200
    "<p>Short URL: <a href='http://localhost:4567/#{short_code}'>http://localhost:4567/#{short_code}</a></p>" \
    "<p><a href='/qr/#{short_code}'>Get QR Code</a></p>"
  rescue => e
    status 400
    "<p>Error: #{e.message}</p><p><a href='/'>Go back</a></p>"
  end
end

# Route to generate QR code for a short URL
get '/qr/:short_code' do
  short_code = params[:short_code]
  short_url = "http://localhost:4567/#{short_code}"

  content_type 'image/svg+xml'
  shortener.generate_url_code(short_url)
end

# Route to handle redirection from short URL
get '/:short_code' do
  short_code = params[:short_code]
  long_url = shortener.retrieve_url(short_code)

  if long_url
    encoded_redirect_url = URI.encode(long_url)
    redirect encoded_redirect_url
  else
    "Short URL not found!"
  end
end

# Route to display statistics for a short URL
get '/stats/:short_code' do
  short_code = params[:short_code]
  stats = shortener.get_stats(short_code)

  if stats
    content_type 'text/html'
    "<h3>Statistics for Short URL: #{short_code}</h3>" \
    "<p>Original URL: #{URI.decode_www_form_component(stats['long_url'])}</p>" \
    "<p>Created at: #{stats['created_at']}</p>" \
    "<p>Last accessed: #{stats['last_accessed'] || 'Never'}</p>" \
    "<p>Click count: #{stats['click_count']}</p>"
  else
    "No statistics available for this short URL."
  end
end
