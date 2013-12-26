class StoryUpdater
  include HTTParty
  
  BASEURL = ENV['BASEURL']
  QA_LABELS = ["qa","qa-pending","qa-done"]
  
  def initialize(story)
    @full_story = story
    StoryUpdater.headers({'X-TrackerToken' => ENV['APIKEY'].to_s,
                             'Content-type' => 'application/json'})
  end
  
  #Any triggers that need to fire based on ticket creation
  def update_on_create
    case @full_story['story_type']
      when "chore"
        set_labels(:add_dev_test)
      end
  end
  
  #Any triggers that need to fire based on ticket updates
  def update_on_update
    if (@full_story['labels'].include? "name" and @full_story['labels']['name'].eql? "dev-test") 
      return
    end
    if ['release', 'chore'].include? @full_story['story_type']
      return
    end

    case @full_story['current_state']
      when "accepted"
        set_labels(:add_pending)
      when "rejected"
        set_labels(:remove_qa)
      end
  end

  #Generic function to ingest updates and push them to PT
  def update_story(h)
    target_url = BASEURL.gsub('PROJECT_ID',@full_story['project_id'].to_s).gsub('STORY_ID',@full_story['id'].to_s)
    # story_wrapper = {"story"=>h} #Need to wrap in a story tag for PT
    # update_xml = story_wrapper.to_xml
    StoryUpdater.put(target_url,:body => h)
  end
  
#####Manipulation Functions#######
  
  def set_labels(func)
    update_story({'labels'=>self.send(func, get_labels)})
  end
  
  def add_dev_test labels
    labels.prepend("dev-test,")
  end
  
  def add_pending labels
    labels << "qa-pending" if (get_labels & QA_LABELS).empty? #ampersand is intersection of two arrays.  Only add qa-pending if it doesn't already have qa labels
  end

  def remove_qa labels
    labels.delete_if {|label| QA_LABELS.include? label}
  end

##Helper Functions#############

  
  def get_labels
    puts @full_story
    @full_story['labels'] || []
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