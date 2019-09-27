require "colorize"
require "./command"
require "./map"
require "./queue"
require "./resources"
require "./world"

UserWorld = World.new

def normalize_command(cmd)
  cmd.downcase.gsub(/\s+/, ' ').strip
end

def run_command(cmd)
  case
  when md = /^st/.match(cmd)
    printf "Stat:\n\tTime: %d\n\tCrystals: %d\n\tTarraform: %d\n",
      UserWorld.ts,
      UserWorld.resources[ResourceType::Crystal],
      UserWorld.resources[ResourceType::Terraformation]
  when md = /^m/.match(cmd)
    UserWorld.map.print
  when md = /^run (?P<ts>\d+)$/.match(cmd)
    ts = md["ts"].to_i32
    UserWorld.run(ts)
    printf "Run to %d\n", ts
  when md = /^harv (?P<x>\d+)\s+(?P<y>\d+)$/.match(cmd)
    x = md["x"].to_i32
    y = md["y"].to_i32
    UserWorld.push(BuildCrystalHarvesterCommand.new(Point.new(x, y)))
    printf "Build harvester at %d %d\n", x, y
  when md = /^rest (?P<x>\d+)\s+(?P<y>\d+)$/.match(cmd)
    x = md["x"].to_i32
    y = md["y"].to_i32
    UserWorld.push(BuildCrystalRestorerCommand.new(Point.new(x, y)))
  when md = /^terr (?P<x>\d+)\s+(?P<y>\d+)$/.match(cmd)
    x = md["x"].to_i32
    y = md["y"].to_i32
    UserWorld.push(BuildTerraformerCommand.new(Point.new(x, y)))
  else
    printf "Out > %s\n", cmd
  end
  printf "\n"
end

loop do
  printf "In > "
  cmd = read_line()
  norm = normalize_command(cmd)
  if norm == "exit"
    break
  end
  run_command(norm)
end

# w.map.print
# w.push(BuildCrystalHarvesterCommand.new(Point.new(2, 3)))
# w.push(BuildCrystalRestorerCommand.new(Point.new(1, 2)))
# w.push(BuildTerraformerCommand.new(Point.new(3, 2)))
# w.run(2000)
# w.map.print
# pp w.resources
