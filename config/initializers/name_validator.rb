class NameValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    !!(value.to_s =~ /\A[a-zA-Z\_]+\z/i)
  end

  def self.build(param_description, argument, options, block)

    if argument == "Name"
      self.new(param_description, argument)
    end
  end

  def description
    "Must be #{@type}. Name can only contains letters and _"
  end
end