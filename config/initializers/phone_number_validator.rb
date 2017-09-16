class PhoneValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    return false if value.to_s.length < 6
    !!(value.to_s =~ /^(\+[1-9])?(\d{6,14}|(\d{3}\-){2,3}\d{2,5})$/)
  end

  def self.build(param_description, argument, options, block)

    if argument == "Phone"
      self.new(param_description, argument)
    end
  end

  def description
    "Not a valid number"
  end
end

