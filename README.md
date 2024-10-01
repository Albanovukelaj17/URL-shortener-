## **URL Shortener with QR Code Generation**

A simple URL shortener built with Sinatra, Ruby, and YAML for data storage. This project allows users to shorten URLs, create custom short codes, generate QR codes for shortened URLs, and track statistics such as the number of clicks and the last access time.

**Features** <br></br>
-URL Shortening: Convert long URLs into short, easily shareable links.<br></br>
-Custom Short Codes: Users can create custom short codes or let the system generate a random code.<br></br>
-QR Code Generation: Generate a QR code for any shortened URL to easily share it with others.<br></br>
-Statistics: View detailed statistics for each shortened URL, including click count and last access time.<br></br>
-Persistent Storage: URLs and statistics are stored in a YAML file for persistence between server restarts.<br></br>
Installation

Clone the repository:

```bash
git clone https://github.com/your-username/url-shortener.git
```
cd url-shortener
Install the required dependencies:

```bash
bundle install
```
Start the Sinatra server:

```bash
ruby sinatra.rb
```
Open your browser and go to http://localhost:4567 to use the application.
## **Usage**

**Shorten a URL**
Enter a long URL in the input field and submit the form to generate a short URL.
Optionally, provide a custom short code for the URL.
**QR Code**
After shortening a URL, a link to generate a QR code will be provided.
The QR code can be used to quickly access the shortened URL.
**View Statistics**
You can view statistics for each shortened URL, such as the creation date, the last time it was accessed, and the number of clicks.
**Example**
1.Shorten URL: You shorten https://example.com to http://localhost:4567/abc123.
2.QR Code: You get a QR code for http://localhost:4567/abc123.
3.Stats: View statistics for abc123 like clicks and last accessed time.
## **File Structure**

-sinatra.rb: The main Sinatra application file that handles routing for the URL shortening service. It presents a webpage where users can:
Choose from existing shortened URLs stored in the urls.yml file.
Shorten new URLs by either using a randomly generated code or a custom code.
Optionally view a QR code for the shortened URL.<br></br>
-urls.yml: A YAML file used to store shortened URLs along with associated metadata such as click count, creation time, and last access time.<br></br>
-Gemfile: Specifies the project's dependencies, including Sinatra, RQRCode, and YAML.<br></br>
-README.md: Documentation for the project, including setup instructions and feature descriptions.<br></br>
-main.rb: A Ruby script that provides terminal-based URL shortening and retrieval of long URLs, separate from the web interface. <br></br>

## **Dependencies**
-Ruby 2.7 or higher<br></br>
-Sinatra<br></br>
-RQRCode<br></br>
-YAML<br></br>

