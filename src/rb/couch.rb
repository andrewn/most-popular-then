require 'rubygems'
require 'typhoeus'
require 'JSON'

module Couch
	class Server
    
    SLASH = "/"
    PORT  = ":"
    
    def initialize(host, port="80", options = nil)
      @host = host
      @port = port
      @options = options
      
      @full_host = @host + PORT + @port
      
      @debug = @options && @options[:debug] ? true : false
      
      if @options && @options[:database]
        @full_host += SLASH + @options[:database]
      end
      
      @on_success = lambda {|response| JSON.parse(response.body)}
      @on_failure = lambda {|response| puts "error code: #{response.code} " + response.body }
    end
	  
	  def delete(uri)
	    
	    puts "DELETE: " + @full_host + SLASH + uri if @debug
	    
	    Connection.delete( @full_host + SLASH + uri, 
	                        :on_success => @on_success,
	                        :on_failure => @on_failure )
    end
    
    def get(uri)
      
      puts "GET: " + @full_host + SLASH + uri if @debug
      
      Connection.get( @full_host + SLASH + uri, 
                      :on_success => @on_success,
                      :on_failure => @on_failure )
    end
    
    def put(uri, json)
      
      puts "PUT: " + @full_host + SLASH + uri if @debug
      puts json if @debug
      
      Connection.put( @full_host + SLASH + uri,
                      :on_success => @on_success,
                      :on_failure => @on_failure,
                      :body => json )
    end
    
    def post(uri, json)
      
      puts "POST: " + @full_host + SLASH + uri if @debug
      puts json if @debug
      
      Connection.put( @full_host + SLASH + uri,
                      :on_success => @on_success,
                      :on_failure => @on_failure,
                      :body => json )
    end
    
    class Connection
	    include Typhoeus
    end
	end
end
