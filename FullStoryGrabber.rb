class FullStoryGrabber
  include HTTParty
  
  attr_accessor :project, :story 
  attr_reader :fullStory
  
  def initialize(project,story)
    self.project = project
    self.story = story
    FullStoryGrabber.headers 'X-TrackerToken' => ENV['APIKEY'].to_s
  end
  
  def get_url
    target_url = "http://www.pivotaltracker.com/services/v3/projects/#{@project}/stories/#{@story.text}"
  end
  
  def get_story
    @fullStory = FullStoryGrabber.get(get_url).parsed_response
  end
  
  def get_labels
    @fullStory['story']['labels'].split(',')
  end
end