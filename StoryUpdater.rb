class StoryUpdater
  include HTTParty
  
  BASEURL = 'http://www.pivotaltracker.com/services/v3/projects/PROJECT_ID/stories/STORY_ID'
  def initialize(story)
    @full_story = story
    StoryUpdater.headers({'X-TrackerToken' => ENV['APIKEY'].to_s,
                             'Content-type' => 'application/xml'})
  end
  
  #Any triggers that need to fire based on ticket creation
  def update_on_create
    case @full_story['story']['story_type']
      when "chore"
        set_labels(:add_dev_test)
      end
  end
  
  #Any triggers that need to fire based on ticket updates
  def update_on_update
    case @full_story['story']['current_state']
      when "accepted"
        set_labels(:add_pending)
      when "rejected"
        set_labels(:remove_qa)
      end
  end
  
  def set_labels(func)
    labels = get_labels
    self.send(func, labels)
    update_story({'labels'=>my_strip(labels,',')})
  end
  
  def add_dev_test labels
    labels.prepend("dev-test,")
  end
  
  def add_pending labels
    labels.prepend("qa-pending,") unless get_labels.include? "qa"
  end

  def remove_qa labels
    labels = labels.gsub(/,?qa-pending,?/,',').gsub(/,?qa-done,?/,',').gsub(/,?qa,?/,',')
  end
  
  def get_labels
    @full_story['story']['labels'] || ""
  end
  
  #Generic function to ingest updates and push them to PT
  def update_story(h)
    puts "Hello logs!"
    target_url = BASEURL.gsub('PROJECT_ID',@full_story['story']['project_id'].to_s).gsub('STORY_ID',@full_story['story']['id'].to_s)
    story_wrapper = {"story"=>h} #Need to wrap in a story tag for PT
    update_xml = story_wrapper.to_xml
    StoryUpdater.put(target_url,:body => update_xml)
    puts "\nTarget URL: " << target_url
    puts @full_story.to_s
  end
  
  def to_s
    "\nFull Story: #{@full_story}\n"
  end
end

def my_strip(string, chars)
  chars = Regexp.escape(chars)
  string.gsub(/\A[#{chars}]+|[#{chars}]+\Z/, "")
end

#Straightforward class addition to replace nokogiri in here.
class Hash
  def to_xml
    map do |k, v|
      text = Hash === v ? v.to_xml : v
      "<%s>%s</%s>" % [k, text, k]
    end.join
  end
end