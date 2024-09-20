require 'securerandom'
require 'yaml'

class URLShortener
    def initialize
        @url_data= {}
    end

    def shorten_url(long_url)
        short_code= SecureRandom.alphanumeric(6)
        @url_data[short_code]= long_url
        puts "Short URL: http://short.ly/#{short_code}"
    end
end

def test_url_shortener
    shortener = URLShortener.new  
    puts "Gib eine URL ein, um sie zu kürzen:"
    long_url = gets.chomp  # Nimmt eine URL vom Benutzer entgegen
    shortener.shorten_url(long_url)  
  end
  

  test_url_shortener