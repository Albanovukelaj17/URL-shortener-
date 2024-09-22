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

  def shorten_url(long_url, custom_code = nil)
  short_code = custom_code || SecureRandom.alphanumeric(6)

  if @url_data.key?(short_code)
    raise "Short code '#{short_code}' is already taken. Please choose another one."
  end

  encoded_url = URI.encode_www_form_component(long_url)
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
    <html>
      <head>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
          }
          .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 600px;
            width: 100%;
          }
          h1 {
            color: #333;
            font-size: 36px;
            margin-bottom: 20px;
          }
          label {
            font-size: 18px;
            color: #555;
          }
          input[type="text"] {
            width: 80%;
            padding: 10px;
            margin: 20px 0;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 5px;
          }
          button {
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
          }
          button:hover {
            background-color: #218838;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>URL Shortener</h1>
          <form action="/shorten" method="POST">
            <label for="url">Enter URL to shorten:</label><br>
            <input type="text" id="url" name="url" placeholder="Enter a long URL here..."><br>
            <label for="custom_code">Optional: Enter custom short code:</label><br>
            <input type="text" id="custom_code" name="custom_code" placeholder="Enter custom short code (optional)"><br>
            <button type="submit">Shorten URL</button>
          </form>
        </div>
      </body>
    </html>
  HTML
end


# Route to shorten a URL
# Route to shorten a URL
post '/shorten' do
  long_url = params[:url]
  custom_code = params[:custom_code]
  
  begin
    short_code = shortener.shorten_url(long_url, custom_code)
    content_type 'text/html'
    status 200

    "<p>Short URL: <a href='http://localhost:4567/#{short_code}'>http://localhost:4567/#{short_code}</a></p>" \
    "<p><a href='/qr/#{short_code}'>Get QR Code</a></p>" \
    "<p><a href='/stats/#{short_code}'>View Statistics</a></p>" # Link to view statistics
  rescue => e
    status 400
    "<p>Error: #{e.message}</p><a href='/'>Go back</a>"
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
