require_relative 'instance_counter'
require_relative 'validate'

class Station
  include InstanceCounter
  include Validation
  attr_reader :trains , :station_name

  @@stations = []

  def self.all
    @@stations
  end

  def initialize(station_name)
    @station_name = station_name
    @trains = []
    @@stations << self
    register_instance
    validate!
  end

  def train_arrived(train)
    @trains << train
  end

  def train_send(train)
    @trains.delete(train)
  end

  def show_cargo_trains
    @trains.select { |train| train.train_type == :cargo }
  end

  def show_passenger_trains
    @trains.select { |train| train.train_type == :passenger }
  end

  def validate!
    raise ArgumentError, "Название станции не может быть пустым" if @station_name.empty?
  end

end
