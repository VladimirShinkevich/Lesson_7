require_relative "station"
require_relative "train"
require_relative "route"
require_relative "passenger_train"
require_relative "cargo_train"
require_relative "wagon"
require_relative "passenger_wagon"
require_relative "cargo_wagon"
require_relative 'menu'
require_relative 'instance_counter'
require_relative 'company'

class Menu
  include Company
  include InstanceCounter
  private

  attr_writer :trains, :stations, :routes

  public

  attr_reader :routes, :stations, :trains

  def initialize
    @stations = []
    @trains = []
    @routes = []
    @stop = false
  end

  def start_railway
    loop do
      if @stop
        puts "Всего хорошего!!!"
        break
      else
        puts MAIN_MENU
        puts "Введите действие (1 - 3): "
        choose = gets.chomp.to_i
        main_menu(choose)
      end
    end
  end

  private

  def main_menu(choose)
    case choose
    when 1
      create_object
    when 2
      perform_menu
    when 3
      @stop = true
    end
  end

  def create_object
    puts CREATE_MENU
    choose = gets.chomp.to_i
    case choose
    when 1
      create_train
    when 2
      create_route
    when 3
      create_station
    end
  end

  def perform_menu
    puts TRAIN_MENU
    choose = gets.chomp.to_i
    case choose
    when 1
      trains_manage
    when 2
      routes_manage
    end
  end

  def trains_manage
    if @trains.empty?
      puts "Нет доступных поездов!"
      create_train
    else
      @trains.each_with_index {|train, index| puts "Индекс поезда - #{index} (Номер поезда - #{train.number}, Тип поезда - #{train.train_type})"}
      puts "Введите индекс поезда: "
      train_index = gets.chomp.to_i
      puts PERFORM_MENU
      puts "Выберите действие (1 - 5): "
      choose = gets.chomp.to_i
      case choose
      when 1
        add_train_to_route(train_index)
      when 2
        add_wagons_to_train(train_index)
      when 3
        delete_train_wagons(train_index)
      when 4
        move_train_next_station(train_index)
      when 5
        move_train_prev_station(train_index)
      end
    end
  end

  def routes_manage
    if @routes.empty?
      puts "Нет доступных маршрутов!"
      create_route
    else
      @routes.each_with_index {|route, index| puts "Индекс маршрута - #{index}, название: #{route.show_route.map {|station| station.station_name}}"}
      puts "Введите индекс маршрута: "
      route_index = gets.chomp.to_i
      puts ROUTE_MENU
      choose = gets.chomp.to_i
      case choose
      when 1
        add_stations_to_route(route_index)
      when 2
        delete_stations_from_route(route_index)
      end
    end
  end
end

def create_station
  loop do
    puts "Для добавления станций введите - 1"
    puts "Когда завершите нажмите - 2"
    choose = gets.chomp.to_i
    case choose
    when 1
      print "Введите название станции: "
      station_name = gets.chomp
      @stations << Station.new(station_name)
      puts "Станция добавлена!"
    when 2
      puts "Станции добавлены!!!"
      break
    end
  end
rescue ArgumentError => e
  puts e.message
  puts "Повторите попытку!"
  retry
end

def create_train
  print "Введите номер поезда: "
  train_number = gets.chomp
  puts "Пассажирский = 1"
  puts "Грузовой = 2"
  puts "Введите тип поезда: "
  train_type = gets.chomp.to_i
  @trains << PassengerTrain.new(train_number) if train_type == 1
  @trains << CargoTrain.new(train_number) if train_type == 2
  puts "Поезд добавлен"
rescue ArgumentError => e
  puts e.message
  puts "Повторите попытку!"
  retry
end

def create_route
  if @stations.empty?
    puts "Нет доступных станций для создания маршрута!"
    create_station
  else
    @stations.each_with_index {|station, index| puts "Индекс станции #{index}: Название станции - #{station.station_name}"}
    puts "Введите индекс начальной станции: "
    start_station_index = gets.chomp.to_i
    puts "Введите индекс последней станции: "
    end_station_index = gets.chomp.to_i
    @routes << Route.new(@stations[start_station_index], @stations[end_station_index])
    puts "Маршрут создан!"
  end
rescue ArgumentError => e
  puts e.message
  puts "Повторите попытку!"
  retry
end

def add_train_to_route(train_index)
  if @routes.empty?
    puts "Нет доступных маршрутов!"
    create_route
  else
    @routes.each_with_index {|route, index| puts "Индекс маршрута - #{index}, название: #{route.show_route {|station| station.station_name}}"}
    puts "Введите индекс маршрута: "
    route_index = gets.chomp.to_i
    @trains[train_index].add_train_to_route(@routes[route_index])
    puts "Поезд на маршруте! "
  end

end

def add_wagons_to_train(train_index)
  if @trains.empty?
    puts "Нет доступных поездов!"
    create_train
  else
    wagon = CargoWagon.new(:cargo) if @trains[train_index].train_type == :cargo
    wagon = PassengerWagon.new(:passenger) if @trains[train_index].train_type == :passenger
    @trains[train_index].add_wagon(wagon)
    puts "Вагон прицеплен!"
  end
end

def delete_train_wagons(train_index)
  if @trains.empty?
    puts "Нет доступных поездов!"
    create_train
  else
    if @wagons.empty?
      puts "Все вагоны отцеплены!"
    end
      @trains[train_index].delete_wagon
      puts "Вагон отцеплен от поезда"
  end
end

def move_train_next_station(train_index)
  if @routes.empty?
    puts "Нет доступных маршрутов!"
    create_route
  else
    if @current_station != @end_station
      @trains[train_index].train_moving_next
      puts "Поезд отправлен на следующею станцию!"
    else
      puts "Поезд прибыл на конечную станцию!"
    end

  end
end

def move_train_prev_station(train_index)
  if @routes.empty?
    puts "Нет доступных маршрутов!"
    create_route
  else
    @trains[train_index].train_moving_prev
  end

end

def add_stations_to_route(route_index)
  if @routes.empty?
    puts "Нет доступных маршрутов!"
    create_route
  else
    @stations.each_with_index {|station, index| puts "Индекс станции #{index}: Название станции - #{station.station_name}"}
    puts "Введите индекс станции: "
    station_index = gets.chomp.to_i
    @route[route_index].add_intermediate_station(@stations[station_index])
    puts "Станция добавлена на маршрут!"
  end
end

def delete_stations_from_route(route_index)
  if @routes.empty?
    puts "Нет доступных маршрутов!"
    create_route
  else
    @stations.each_with_index {|station, index| puts "Индекс станции #{index}: Название станции - #{station.station_name}"}
    puts "Введите индекс станции: "
    station_index = gets.chomp.to_i
    station = @routes[route_index].show_route[station_index]
    @route[route_index].delete_intermediate_station(station)
  end
end

railway = Menu.new
railway.start_railway
