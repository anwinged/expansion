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

def render_map(world)
  size = world.map.size
  (0...size).each do |x|
    if x == 0
      printf "+"
      (0...size).each do |y|
        printf "-----+"
      end
      print "\n"
    end
    printf "|"
    (0...size).each do |y|
      tile = world.map.get(x, y)
      printf "%c  %d%d|", tile.letter, x, y
    end
    print "\n"
    printf "|"
    (0...size).each do |y|
      printf "     |"
    end
    print "\n"
    printf "|"
    (0...size).each do |y|
      tile = world.map.get(x, y)
      if tile.letter == 'f'
        printf "%5d|", world.map.get(x, y).cur
      else
        printf "     |", world.map.get(x, y).cur
      end
    end
    print "\n"
    printf "+"
    (0...size).each do |y|
      printf "-----+"
    end
    print "\n"
  end
end

def render_commands(world)
  items = world.queue.top(5)
  if items.size != 0
    printf "Queue:\n"
  end
  time = ->(ts : Int64) { Time.unix(ts).to_local.to_s }
  items.each do |i|
    printf "  %s, %s\n", time.call(i.ts), i.command.desc
  end
end

def render_resources(world)
  printf "Resources:\n  Crystals:       %5d\n  Terraformation: %5d\n",
    world.resources[Game::ResourceType::Crystal],
    world.resources[Game::ResourceType::Terraformation]
end

def render_world(world)
  printf "Now:\n  %s\n\n", Time.unix(world.ts).to_local.to_s
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

printf "\u{001b}[2J"
loop do
  render_world world
  printf "In > "
  cmd = read_line()
  norm = normalize_command(cmd)
  if norm == "exit"
    break
  end
  printf "\u{001b}[2J"
  current_time = Time.local.to_unix
  world.run current_time
  router.handle cmd
  printf "\n"
end
