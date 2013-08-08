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
    case @full_story['story_type']
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
    self.send(func)
    update_story({'labels'=>labels})
  end
  
  def add_dev_test
    labels.prepend("dev-test")
  end
  
  def add_pending
    labels.prepend("qa-pending,")
  end

  def remove_qa
    labels = labels.gsub(/,?qa-pending,?/,',').gsub(/,?qa,?/,',')
  end
  
  def get_labels
    @full_story['story']['labels'] || ""
  end
  
  #Generic function to ingest updates and push them to PT
  def update_story(h)
    target_url = BASEURL.gsub('PROJECT_ID',@full_story['story']['project_id'].to_s).gsub('STORY_ID',@full_story['story']['id'].to_s)
    update_xml = Nokogiri::XML::Builder.new do
      story {
        to_nodes(h)
        test "test"
      }
    end
    StoryUpdater.put(target_url,:body => update_xml.doc.root.to_xml)
  end
end

def to_nodes(h)
  h.each {|key, value| puts "#{key} #{mystrip(value,',')}"}
end

def my_strip(string, chars)
  chars = Regexp.escape(chars)
  string.gsub(/\A[#{chars}]+|[#{chars}]+\Z/, "")
end