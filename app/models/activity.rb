class Activity < ActiveRecord::Base
  belongs_to :event
  
  def popularity
    neutral + positive + negative
  end

  def satisfaction
    return 1  if positive > negative and positive > neutral
    return -1 if negative > positive and negative > neutral
    0
  end

  def self.update_trends(event_id, tweet)
    self.find_all_by_event_id(event_id).each do |activity|
      if tweet.text =~ /(##{activity.tag})/i
        if tweet.text =~ Qualification.positive_tag_regex
          activity.update_attribute :positive, activity.positive + 1
        elsif tweet.text =~ Qualification.negative_tag_regex
          activity.update_attribute :negative, activity.negative + 1
        else
          activity.update_attribute :neutral, activity.neutral + 1
        end
      end
    end
  end
end
