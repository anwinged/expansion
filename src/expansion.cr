require "./game/command"
require "./game/map"
require "./game/queue"
require "./game/resources"
require "./game/world"
require "./cli/command_router"

ts = Time.local.to_unix
world = Game::World.new(ts)

router = CLI::CommandRouter.new

router.add "st" do
  printf "Stat:\n\tTime: %s\n\tCrystals: %d\n\tTarraform: %d\n",
    Time.unix(world.ts).to_local.to_s,
    world.resources[Game::ResourceType::Crystal],
    world.resources[Game::ResourceType::Terraformation]
end

router.add "m" do
  world.map.print
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

def normalize_command(cmd)
  cmd.downcase.gsub(/\s+/, ' ').strip
end

loop do
  printf "In > "
  cmd = read_line()
  norm = normalize_command(cmd)
  if norm == "exit"
    break
  end
  current_time = Time.local.to_unix
  world.run current_time
  router.handle cmd
  printf "\n"
end
