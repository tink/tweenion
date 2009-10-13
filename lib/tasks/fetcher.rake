namespace :tweet do
  desc 'Keeps searching twitter API for new tweets about the event tag'
  task :fetch => :environment do
    unless ENV.include?('event')
      raise 'usage: rake tweet:fetch event=[tag] #[tag] is the event tag set on the event'
    end
    event = Event.find_by_tag(ENV['event'])
    if event.nil?
      raise "there is no such event called #{ENV['event']}. Please try again!"
    end
    event.fetch_new_tweets
  end
end
