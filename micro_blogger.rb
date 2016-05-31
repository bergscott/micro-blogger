require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Did not post tweet! Message was over 140 characters long."
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    screen_names = @client.followers.collect do |follower| 
      @client.user(follower).screen_name.downcase
    end
    if screen_names.include?(target.downcase)
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "Could not send DM. User @#{target} does not follow CaveBot"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end

  def everyones_last_tweet
    friends = @client.friends.to_a
    friends.sort_by! { |friend| @client.user(friend).screen_name.downcase }
    friends.each do |friend|
      user = @client.user(friend)
      timestamp = user.status.created_at
      puts "#{user.screen_name} said this on "\
           "#{timestamp.strftime("%A, %b %d")}..."
      puts "#{user.status.text}"
      puts "" #blank line
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    bitly.shorten(original_url).short_url
  end

  def run
    puts "Welcome to the CaveBot Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q' then puts "Goodbye!"
      when 't' then tweet(parts[1..-1].join(" "))
      when 'dm' then dm(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_followers(parts[1..-1].join(" "))
      when 'elt' then everyones_last_tweet
      when 's' then shorten(parts[1..-1].join(" "))
      when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end
end

blogger = MicroBlogger.new
blogger.run
