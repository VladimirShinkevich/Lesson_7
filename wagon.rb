require_relative 'company'
require_relative 'validate'

class Wagon
  include Company
  include Validation
  attr_reader :wagon_type

  def initialize(wagon_type)
    @wagon_type = wagon_type
    validate!
  end

  def validate!
    raise ArgumentError, "Неправильный тип вагона" if @wagon_type != (:passenger || :cargo)
  end

end
