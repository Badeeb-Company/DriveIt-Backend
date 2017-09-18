class Driver < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  enum driver_states: [:available, :in_trip, :offline]

  validates_uniqueness_of :phone

  before_create :generate_access_token
  after_create :firebase_migrate
  def firebase_migrate
    firebase = Firebase::Client.new(FIR_Base_URL)
    response = firebase.set("drivers/#{self.id}/", { :state => "available", :trip => {:client_address => "", :client_image_url => "", :client_lat => 0, :client_long => 0 , :client_name => "", :client_phone => "", :id => -1}})
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

  private 
  def generate_access_token
  	self.token = Devise.friendly_token(length = 100)
  	self.driver_state = Driver.driver_states[:available]
  end

end
