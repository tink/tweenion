require 'twitter_search'

class Event < ActiveRecord::Base
  has_many :activities

  def fetch_new_tweets
    client = TwitterSearch::Client.new 'tweenion'
    last_id = self.last_tweet_id || 0
    tweets = client.query :q => self.tag, :rpp => 100, :since_id => last_id 
    tweets.each do |tweet|
      Activity.update_trends self.id, tweet
    end
    update_attribute :last_tweet_id, tweets.first.id if tweets.size > 0
  end
end
