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
        set_labels(:add_dev_test) unless get_labels.include? "dev-test"
      end
  end
  
  #Any triggers that need to fire based on ticket updates
  def update_on_update
    if get_labels.include? "dev-test"
      return
    end
    if ['release', 'chore'].include? @full_story['story_type']
      puts "no action on release or chore"
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
    # target_url = "http://requestb.in/187efvm1" ##REMOVE
    StoryUpdater.put(target_url,:body => h.to_json)
  end
  
#####Manipulation Functions#######
  
  def set_labels(func)
    update_ary = []
    new_label_list = self.send(func, get_labels)
    puts "new label list: #{new_label_list}"
    new_label_list.each do |label|
      update_ary << {name: label}
    end
    update_story({'labels'=> update_ary})
    puts "Updating #{@full_story["id"]} with #{func}"
  end
  
  def add_dev_test labels
    labels << "dev-test"
  end
  
  def add_pending labels
    labels << "qa-pending" if (get_labels & QA_LABELS).empty? #ampersand is intersection of two arrays.  Only add qa-pending if it doesn't already have qa labels
  end

  def remove_qa labels
    labels.delete_if {|label| QA_LABELS.include? label}
  end


##Helper Functions#############
  
  def get_labels
    @full_story['labels'].map {|x| x["name"]} || []
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