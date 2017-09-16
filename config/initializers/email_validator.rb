class EmailValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    !!(value.to_s =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def self.build(param_description, argument, options, block)

    if argument == "Email"
      self.new(param_description, argument)
    end
  end

  def description
    "Must be #{@type}."
  end
end