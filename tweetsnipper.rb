#!/usr/bin/env ruby
#
# gem install twitter
# gem install dotenv # if you use a .env file, otherwise:
# export CONSUMER_KEY="..." CONSUMER_SECRET="..." ACCESS_TOKEN="..." ACCESS_SECRET="..."
# ruby __FILE__
#

require 'twitter'
require 'twitter/entities'

if File.exists?(File.join(File.dirname(__FILE__), '.env'))
	require 'dotenv'
	Dotenv.load
end

raise "Missing credentials!" unless ENV['CONSUMER_KEY'] || ENV['CONSUMER_SECRET'] || ENV['ACCESS_TOKEN'] || ENV['ACCESS_SECRET']

t_client = Twitter::REST::Client.new do |c|
	c.consumer_key = ENV['CONSUMER_KEY']
	c.consumer_secret = ENV['CONSUMER_SECRET']
	c.access_token = ENV['ACCESS_TOKEN']
	c.access_token_secret = ENV['ACCESS_SECRET']
end

# Get a user's tweets, most recent first.
ht_tl_a = t_client.user_timeline(ENV['TWITTER_USERNAME'], { :trim_user => true, :include_rts => false, :count => 200 }).
	select do |t|
		is_time_hashtag = false
		if t.hashtags?
			t.hashtags.each do |ht|
				is_time_hashtag = true unless (ht.text.to_s =~ /^\d+[mhd]$/).nil?
			end
		end
		is_time_hashtag
	end

# Store last retrieved timestamp.
# since_id = ht_tl_a.last.id unless ht_tl_a.last.nil?

puts "Will delete the following tweets:"

# Select expired tweets to delete.
delete_candidates = ht_tl_a.collect do |t|
	expired_tweet = false
	t.hashtags.each do |ht|
		hashtag = ht.text.to_s
		unless (hashtag =~ /^\d+[mhd]$/).nil?
			# test for expiry.
			created_at = t.created_at.to_i
			elapsed_s = 0
			hashtag.match(/^(?<num>\d+)(?<unit>[mhd])$/) do |m|
				elapsed_s = m[:num].to_i
				case m[:unit]
				when "m" # minute
					elapsed_s *= 60
				when "h" # hour
					elapsed_s *= 60 * 60
				when "d" # day
					elapsed_s *= 60 * 60 * 24
				end
			end
			difference = Time.now.to_i - created_at
			# p Time.at(difference).utc.to_s
			# p Time.at(elapsed_s).utc.to_s
			expired_tweet = true if difference > elapsed_s
		end
	end
	if expired_tweet
		puts "* #{t.text}."
		t.id
	end
end

# Really Delete Tweets
t_client.destroy_status(delete_candidates, { :trim_user => true }) unless delete_candidates.empty?

puts "Done!"