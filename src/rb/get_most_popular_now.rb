require 'rubygems'
require 'typhoeus'
require 'hpricot'
require 'json'
require 'couch'
require 'uuid'

# Define some helper classes
class BBCNews
  include Typhoeus
  
  attr_accessor :html, :response

  def initialise
  end
  
#  remote_defaults :on_success => lambda {|response| puts "------ got\n"}, #JSON.parse(response.body)},
#                  :on_failure => lambda {|response| puts "error code: #{response.code}"},
#                  :base_uri   => "http://news.bbc.co.uk"
    
    remote_defaults :base_uri => "http://news.bbc.co.uk"

    define_remote_method :front_page_raw, :path => '/'
    
    define_remote_method :front_page_html, :path => '/', 
                         :on_success => lambda { |response|
                           bbc_instance = BBCNews.new
                           bbc_instance.html = Hpricot(response.body) 
                           bbc_instance.response = response
                           bbc_instance
                         }
end

class MostPopularItem
  
  attr_accessor :position, :story_url, :story_id, :date, :type
  
  def inspect
    "MostPopularNow #{@story_url}"
  end
  
  def to_json
    struct = {
      "position" => @position,
      "story_url" => @story_url,
      "story_id" => @story_id,
      "date" => @date,
      "type" => @type
    }
    
    return JSON.pretty_generate( struct )
  end
  
  # Static convenience methods -----------------------
  
  def self.parseHTML( fragment="" )
    unless fragment.kind_of? Hpricot
      fragment = Hpricot.new( fragment )
    end
    
    mpi = MostPopularItem.new
    mpi.position  = self.get_position_from_class_name( fragment.attributes["class"].to_s )
    mpi.story_url = fragment.search("a")[0].attributes["href"].to_s
    mpi.story_id  = self.url_to_story_id(mpi.story_url).to_s
    
    return mpi;
  end
  
  def self.url_to_story_id(url="")
    return url.match( /\/(\d)*\.stm/ )[0].gsub( /\//, "").gsub( /\.stm/, "")
  end
  
  def self.get_position_from_class_name(class_name="")
    return class_name.gsub( /mp/, "").to_i
  end
  
end

db = Couch::Server.new( "http://localhost", "5984", :database => "mpi", :debug => false)

# Grab news homepage
# as Hpricot HTML
bbc = BBCNews.front_page_html

# Extract most popular blocks (3)
most_popular_blocks = bbc.html.search( ".popstoryList" )

date = bbc.response.headers.match( /Date: ([,: \w])+/ )[0].gsub("Date: ", "")
#p Date.new( date )
types = [ "shared", "read", "watched_listened" ]

# For each most popular block
most_popular_blocks.each_with_index do | most_popular_block, index |
  
  type = types[index]
  
	# Extract list
	most_pop_items = most_popular_block.search( "li" ) 
	puts most_pop_items.length
	
	# For each most pop items
	most_pop_items.each do | most_pop_item |	  
  	# Format as JSON
	  item_as_object = MostPopularItem.parseHTML( most_pop_item )
	  item_as_object.date = date
	  item_as_object.type = type
	  
	  json = item_as_object.to_json
	  uuid = UUID.create_v5( json, UUID::NameSpace_URL).to_s
	  
  	# Push to couchdb
  	db.put( uuid, json )
	end
# End
end