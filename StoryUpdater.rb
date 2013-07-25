class StoryUpdater
  include HTTParty
  
  BASEURL = 'http://www.pivotaltracker.com/services/v3/projects/PROJECT_ID/stories/STORY_ID'
  def initialize(story)
    @full_story = story
    StoryUpdater.headers({'X-TrackerToken' => ENV['APIKEY'].to_s,
                             'Content-type' => 'application/xml'})
  end
  
  def update
    case @full_story['story']['current_state']
        when "accepted"
          update_story(:add_pending)
        when "rejected"
          update_story(:remove_qa)
        end
        
  end
  
  def add_pending
    labels = get_labels
    "qa-pending,".prepend(labels)
    labels
  end

  def remove_qa
    labels = get_labels
    labels = labels.gsub(/,?qa-pending,?/,',').gsub(/,?qa,?/,',')
    labels = '' if labels.eql? ','
    labels
  end
  
  def get_labels
    @full_story['story']['labels'] || ""
  end
  
  def update_story(func)
    target_url = BASEURL.gsub('PROJECT_ID',@full_story['story']['project_id'].to_s).gsub('STORY_ID',@full_story['story']['id'].to_s)
    update_xml = Nokogiri::XML::Builder.new do
      story {
        labels self.send(func)
      }
    end
    response = StoryUpdater.put(target_url,:body => update_xml.doc.root.to_xml)
    puts response
  end
end