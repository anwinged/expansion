class CLI::CommandRouter
  def initialize
    @mappings = [] of {String, Proc(Nil)}
  end

  def add(route, &block)
    @mappings.push({route, block})
  end

  def handle(command)
    @mappings.each do |i|
      if i[0] == command
        i[1].call
      end
    end
  end
end
