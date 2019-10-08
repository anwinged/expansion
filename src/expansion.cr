require "colorize"
require "./game/**"
require "./cli/**"

ts = Time.local.to_unix
world = Game::World.new(ts)

router = CLI::CommandRouter.new

router.add "harv {x} {y}", "Build harvester at x,y" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  point = Game::Point.new(x, y)
  world.push(Game::BuildCrystalHarvesterCommand.new(point))
  printf "Build harvester at %d %d\n", x, y
end

router.add "rest {x} {y}", "Build restorer at x,y" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  point = Game::Point.new(x, y)
  world.push(Game::BuildCrystalRestorerCommand.new(point))
end

router.add "terr {x} {y}", "Build terraformator at x,y" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  point = Game::Point.new(x, y)
  world.push(Game::BuildTerraformerCommand.new(point))
end

router.add "help", "Show all commands" do |p|
  printf "Commands:\n"
  router.routes.each do |r|
    printf "  %s - %s\n", r.route, r.desc
  end
end

def render_time(ts)
  t = Time.unix(ts).in(Time::Location.load("Europe/Moscow"))
  t.to_s("%H:%M:%S")
end

def render_map(world)
  size = world.map.size
  (0...size).each do |x|
    if x == 0
      printf "+"
      (0...size).each do |y|
        printf "------+"
      end
      print "\n"
    end
    printf "|"
    (0...size).each do |y|
      tile = world.map.get(x, y)
      printf "%s   %d%d|", tile.letter.colorize(:green), x, y
    end
    print "\n"
    printf "|"
    (0...size).each do |y|
      printf "      |"
    end
    print "\n"
    printf "|"
    (0...size).each do |y|
      tile = world.map.get(x, y)
      if tile.letter == 'f'
        printf "%6d|", world.map.get(x, y).cur
      else
        printf "      |", world.map.get(x, y).cur
      end
    end
    print "\n"
    printf "+"
    (0...size).each do |y|
      printf "------+"
    end
    print "\n"
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
  printf "Resources:\n  Crystals:       %5d\n  Terraformation: %5d\n",
    world.resources[Game::ResourceType::Crystal],
    world.resources[Game::ResourceType::Terraformation]
end

def render_world(world)
  printf "Now:\n  %s\n\n", render_time(world.ts)
  if world.win?
    printf "YOU WIN!!!\n\n"
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

printf CLEAR_SCREEN_ESC_CODE
loop do
  render_world world
  printf "In > "
  cmd = read_line()
  norm = normalize_command(cmd)
  if norm == "exit"
    break
  end
  printf CLEAR_SCREEN_ESC_CODE
  current_time = Time.local.to_unix
  world.run current_time
  begin
    router.handle cmd
  rescue Game::NotEnoughtResources
    printf ">>> Not enought resources <<<\n"
  rescue Game::InvalidPlaceForBuilding
    printf ">>> Can't build here <<<\n"
  end
  printf "\n"
end
