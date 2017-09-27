class Driver < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  enum driver_states: [:AVAILABLE, :IN_TRIP, :INVITED]
  enum driver_avilability: [:ONLINE, :OFFLINE]
  validates_uniqueness_of :phone

  before_create :generate_access_token
  after_create :firebase_migrate
  def firebase_migrate
    firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
    response = firebase.set("drivers/#{self.id}/", {:trip => {:distance_to_arrive => 0,:time_to_arrive => 0, :client_address => "", :client_id => 0, :client_phone => "", :client_image_url => "", :client_long => 0, :client_lat => 0,:client_name => "", :client_phone => "", :id => 0, :state => ""}
})
    unless response.success?
      self.errors.add(:firebase, "Cannot save record")
      return false
    end
    response = firebase.set("locations/drivers/#{self.id}/", { :long => 0, :lat => 0})
    unless response.success?
      self.errors.add(:firebase, "Cannot save record")
      return false
    end
  end
  def as_json(options)
  	unless options[:auth] == true
	  	options[:except] ||= [:token]
	  end
	   json = super(options)
     return json
  end  
  def map_description
    return "Name: #{self.name}<br /><br />Phone: #{self.phone}<br /><br />Availability: #{Driver.driver_avilabilities.keys[self[:driver_availability]]}\n\nState: #{Driver.driver_states.keys[self[:driver_state]]}"
  end
  private 
  def generate_access_token
  	self.token = Devise.friendly_token(length = 100)
  	self.driver_state = Driver.driver_states[:AVAILABLE]
  end

end
