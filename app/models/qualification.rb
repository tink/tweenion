class Qualification < ActiveRecord::Base
  validates_presence_of :tag

  def self.positive_tag_regex
    tag_regex true
  end
  
  def self.negative_tag_regex
    tag_regex false
  end

  def self.tag_regex(positive)
    tags = ''
    qualifications = self.find_all_by_positive(positive)
    return false if qualifications.size == 0
    qualifications.each do |qualification|
      tags += qualification.tag
      tags += '|' unless qualification == qualifications.last
    end
    puts qualifications.size
    puts "tags: #{tags}"
    /(#{tags})/i
  end
end
