require "./game/command"
require "./game/map"
require "./game/queue"
require "./game/resources"
require "./game/world"
require "./cli/command_router"

world = Game::World.new

router = CLI::CommandRouter.new

router.add "st" do
  printf "Stat:\n\tTime: %d\n\tCrystals: %d\n\tTarraform: %d\n",
    world.ts,
    world.resources[Game::ResourceType::Crystal],
    world.resources[Game::ResourceType::Terraformation]
end

router.add "m" do
  world.map.print
end

router.add "run {ts}" do |p|
  ts = p["ts"].to_i32
  world.run ts
  printf "Run to %d\n", ts
end

router.add "harv {x} {y}" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  world.push(Game::BuildCrystalHarvesterCommand.new(Game::Point.new(x, y)))
  printf "Build harvester at %d %d\n", x, y
end

router.add "rest {x} {y}" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  world.push(Game::BuildCrystalRestorerCommand.new(Game::Point.new(x, y)))
end

router.add "terr {x} {y}" do |p|
  x = p["x"].to_i32
  y = p["y"].to_i32
  world.push(Game::BuildTerraformerCommand.new(Game::Point.new(x, y)))
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
  router.handle cmd
  printf "\n"
end
