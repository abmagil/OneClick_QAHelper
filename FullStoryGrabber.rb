class FullStoryGrabber
  include HTTParty
  
  attr_accessor :project, :story 
  attr_reader :full_story
  
  def initialize(project,story)
    self.project = project
    self.story = story
    FullStoryGrabber.headers 'X-TrackerToken' => ENV['APIKEY'].to_s
    @full_story = FullStoryGrabber.get(get_url).parsed_response
  end
  
  def get_url
    target_url = "http://www.pivotaltracker.com/services/v3/projects/#{@project}/stories/#{@story.text}"
  end

  def to_s
    "\nProject: #{project}\nStory: #{story}\nFull Story #{get_story}"
  end
end