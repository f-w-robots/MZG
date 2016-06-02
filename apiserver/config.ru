require File.dirname(__FILE__) + '/app'

use Rack::Session::Cookie, :secret => ENV['secret']

App.run!
