class Driver < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  enum driver_states: [:AVAILABLE, :IN_TRIP, :INVITED]
  enum driver_avilability: [:ONLINE, :OFFLINE]
  enum driver_types:[:CAR, :BIKE]
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
     if options[:html] == true
        return json.to_json.html_safe
      end
     return json
  end  
  def map_description
    return "Name: #{self.name}, Phone: #{self.phone}, Availability: #{Driver.driver_avilabilities.keys[self[:driver_availability]]}, State: #{Driver.driver_states.keys[self[:driver_state]]}".html_safe
  end
  def availability_string
    if self.driver_availability == Driver.driver_avilabilities[:ONLINE]
      return "Online"
    else
      return "Offline"
    end
  end
  def state_string
    if self.driver_state == Driver.driver_states[:IN_TRIP]
      return "Busy"
    else
      return "Available"
    end
  end
  private 
  def generate_access_token
  	self.token = Devise.friendly_token(length = 100)
  	self.driver_state = Driver.driver_states[:AVAILABLE]
    self.driver_availability = Driver.driver_avilabilities[:OFFLINE]
  end

end
