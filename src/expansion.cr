require "./game/command"
require "./game/map"
require "./game/queue"
require "./game/resources"
require "./game/world"
require "./cli/command_router"

ts = Time.local.to_unix
world = Game::World.new(ts)

router = CLI::CommandRouter.new

router.add "q" do |p|
  items = world.queue.top(5)
  items.each do |i|
    printf "%s, %s\n", Time.unix(i.ts).to_local.to_s, typeof(i.command)
  end
end

router.add "harv {x} {y}" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  point = Game::Point.new(x, y)
  world.push(Game::BuildCrystalHarvesterCommand.new(point))
  printf "Build harvester at %d %d\n", x, y
end

router.add "rest {x} {y}" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  point = Game::Point.new(x, y)
  world.push(Game::BuildCrystalRestorerCommand.new(point))
end

router.add "terr {x} {y}" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  point = Game::Point.new(x, y)
  world.push(Game::BuildTerraformerCommand.new(point))
end

def render_map(world)
  size = world.map.size
  (0...size).each do |x|
    if x == 0
      printf "+"
      (0...size).each do |y|
        printf "---+"
      end
      print "\n"
    end
    printf "|"
    (0...size).each do |y|
      printf "%c%d%d|", world.map.get(x, y).letter, x, y
    end
    print "\n"
    printf "|"
    (0...size).each do |y|
      printf "%3d|", world.map.get(x, y).cur
    end
    print "\n"
    printf "+"
    (0...size).each do |y|
      printf "---+"
    end
    print "\n"
  end
end

def render_resources(world)
  printf "Resources:\n  Crystals:       %5d\n  Terraformation: %5d\n",
    world.resources[Game::ResourceType::Crystal],
    world.resources[Game::ResourceType::Terraformation]
end

def render_world(world)
  printf "Now: %s\n\n", Time.unix(world.ts).to_local.to_s
  if world.win?
    printf "YOU WIN!!!\n\n"
  end
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
