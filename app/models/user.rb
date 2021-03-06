class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum user_states: [:available, :in_trip, :offline]

  validates_uniqueness_of :phone
  before_create :generate_access_token
  after_create :firebase_migrate



  def firebase_migrate
    firebase = Firebase::Client.new(Rails.application.secrets.FIR_Base_URL)
    response = firebase.set("clients/#{self.id}/", { :trip => {:driver_phone => "", :driver_id => 0,:distance_to_arrive => 0, :driver_address => "", :driver_image_url => "", :driver_name => "", :id => 0, :state => "", :time_to_arrive => 0, :state => "", :driver_type => ""}})
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

  def self.new_token
    Devise.friendly_token(length = 100)
  end

  private 
  def generate_access_token
  	self.token = User.new_token
  	self.user_state = User.user_states[:available]
  end


end
