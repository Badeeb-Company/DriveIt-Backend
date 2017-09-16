class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  enum user_types: [:client, :driver]
  enum user_states: [:available, :in_trip, :offline]
  scope :drivers, lambda {where(user_type: User.user_types[:driver])}
  scope :users, lambda {where(user_type: User.user_types[:client])}

  before_create :generate_access_token

  def as_json(options)
  	unless options[:auth] == true
	  	options[:except] ||= [:token]
	end
	json = super(options)
	json ["user_type"] = User.user_types.index(self.user_type)
  	return json
  end  

  private 
  def generate_access_token
  	self.token = Devise.friendly_token(length = 100)
  	self.user_state = User.user_states[:available]
  end


end
