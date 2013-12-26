class FullStoryGrabber
  require 'json'

  include HTTParty
  
  attr_accessor :project_id, :story_id
  attr_reader :full_story
  
  def initialize(project,story)
    self.project_id = project
    self.story_id = story
    FullStoryGrabber.headers 'X-TrackerToken' => ENV['APIKEY'].to_s, 'Content-type' => 'application/json'
    @full_story = JSON.parse FullStoryGrabber.get(get_url).body
  end
  
  def get_url
    ##TODO Update this to use the heroku config variable
    target_url = "https://www.pivotaltracker.com/services/v5/projects/#{@project_id}/stories/#{@story_id}"
  end

  def to_s
    "\nProject: #{project}\nStory: #{story}\nFull Story #{get_story}"
  end
end