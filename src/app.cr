require "colorize"
require "./game/**"
require "./cli/**"

class App
  @ts : Game::TimePoint

  def initialize
    @map = Game::MapGenerator.make 6, 8, 10
    @ts = Time.local.to_unix
    @world = Game::World.new @map, @ts
    @buildings = Game::BuildingFactory.new
    @router = CLI::CommandRouter.new

    @buildings.items.each do |i|
      b = i[:b]
      route = sprintf "%s {x} {y}", b.shortcut
      desc = sprintf "Build %s at x,y", b.name
      @router.add route, desc do |p|
        x = p["x"].to_i32
        y = p["y"].to_i32
        point = Game::Point.new(x, y)
        @world.push(Game::BuildCommand.new(point, b))
        printf "Build %s at %d %d\n", b.name, x, y
      end
    end

    @router.add "help", "Show all commands" do
      printf "Commands:\n"
      @router.routes.each do |r|
        printf "  %s - %s\n", r.route, r.desc
      end
    end
  end

  def render_time(ts)
    t = Time.unix(ts).in(Time::Location.load("Europe/Moscow"))
    # It's future, baby
    t += 200.years
    t.to_s("%Y-%m-%d %H:%M:%S")
  end

  def render_map(world)
    rows = world.map.rows
    cols = world.map.cols
    (0...rows).each do |x|
      if x == 0
        printf "+"
        (0...cols).each do
          printf "------+"
        end
        print "\n"
      end
      printf "|"
      (0...cols).each do |y|
        tile = world.map.get(x, y)
        printf "%s   %d%d\|", render_tile_letter(tile), x, y
      end
      print "\n"
      printf "|"
      (0...cols).each do
        printf "      |"
      end
      print "\n"
      printf "|"
      (0...cols).each do |y|
        tile = world.map.get(x, y)
        printf "%6s|", render_tile_number(tile).to_s
      end
      print "\n"
      printf "+"
      (0...cols).each do
        printf "------+"
      end
      print "\n"
    end
  end

  def render_tile_letter(tile : Game::Tile)
    case tile
    when Game::ConstructionSiteTile then '_'.colorize(:red)
    when Game::DepositTile          then render_deposit_resource tile.dep.type
    when Game::BuildingTile         then render_building_letter tile.building.type
    when Game::PlateauTile          then ' '
    else
      raise "Unknown tile " + typeof(tile).to_s
    end
  end

  def render_building_letter(building_type : Game::Building::Type)
    case building_type
    when Game::Building::Type::StartPoint      then 'S'.colorize(:yellow).underline
    when Game::Building::Type::CrystalMiner    then 'M'.colorize(:yellow)
    when Game::Building::Type::CrystalRestorer then 'R'.colorize(:green)
    when Game::Building::Type::OxygenCollector then 'O'.colorize(:yellow)
    when Game::Building::Type::Smelter         then 'I'.colorize(:magenta)
    when Game::Building::Type::Terraformer     then 'T'.colorize(:cyan)
    else
      raise "Unknown building type " + building_type.to_s
    end
  end

  def render_deposit_resource(res_type : Game::Resource::Type)
    case res_type
    when Game::Resource::Type::Crystals then 'v'.colorize(:blue)
    else
      raise "Unknown resource type " + res_type.to_s
    end
  end

  def render_tile_number(tile : Game::Tile)
    case tile
    when Game::DepositTile then tile.dep.cur
    else
      ' '
    end
  end

  def render_commands(world)
    items = world.queue.top(5)
    if items.size != 0
      printf "Queue:\n"
    end
    wts = world.ts
    items.each do |i|
      ts_diff = i.ts - wts
      if ts_diff < 60
        done_time = sprintf " %02ds", ts_diff
      else
        done_time = sprintf "%d:%02d", ts_diff // 60, ts_diff % 60
      end
      printf "  %s, %s, %s\n", render_time(i.ts), done_time, i.command.desc
    end
  end

  def render_resources(world)
    printf "Resources:\n"
    Game::Resource::Type.each do |t|
      printf "  %-15s %5d\n", t.to_s + ':', world.resources[t]
    end
  end

  def render_world(world)
    printf "Now:\n  %s\n\n", render_time(world.ts)
    if world.win?
      printf "YOU WIN!!! Score: %d\n\n", world.score
    end
    render_commands world
    printf "\n"
    render_resources world
    printf "\n"
    render_map world
    printf "\n"
  end

  def normalize_command(cmd)
    cmd.downcase.gsub(/\s+/, ' ').strip
  end

  CLEAR_SCREEN_ESC_CODE = "\u{001b}[2J"

  def run
    printf CLEAR_SCREEN_ESC_CODE
    loop do
      render_world @world
      printf "In > "
      cmd = read_line()
      norm = normalize_command(cmd)
      if norm == "exit"
        break
      end
      printf CLEAR_SCREEN_ESC_CODE
      current_time = Time.local.to_unix
      @world.run current_time
      begin
        @router.handle cmd
      rescue Game::NotEnoughtResources
        printf ">>> Not enought resources <<<\n"
      rescue Game::InvalidPlaceForBuilding
        printf ">>> Can't build here <<<\n"
      end
      printf "\n"
    end
  end
end
