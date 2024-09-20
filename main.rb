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
    
    def retrieve_url(short_url)
        long_code =@url_data[short_url]
        puts " Short URL is : http://short.ly/#{short_url}"

        if long_code
            puts " Original URL was : http://short.ly/#{long_code}"
        else
            puts " Input a valid short URL"
        end
    end
 
end



def test_url_shortener
    shortener = URLShortener.new  
    puts "Select what you wanna do -> (1: Shorten URL), (2 : Retrieve URL) "
    choice = gets.chomp
    
    case choice
    when "1"
        puts "Enter a URL to shorten"
        long_url = gets.chomp  # scan user
        shortener.shorten_url(long_url)
    when "2"
        puts "Enter the short code to retrieve the original URL "
        short_code = gets.chomp
        shortener.retrieve_url(short_code)
    else
        puts "invalid choice, please neter either 1 or 2"
    end
end

  test_url_shortener