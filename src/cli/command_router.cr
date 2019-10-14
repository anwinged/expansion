class CLI::CommandRouter
  alias RouteHandler = Proc(Hash(String, String), Nil)

  struct Route
    def initialize(@route : String, @pattern : Regex, @desc : String, @handler : RouteHandler)
    end

    getter route
    getter pattern
    getter desc
    getter handler
  end

  def initialize
    @routes = [] of Route
  end

  def add(route : String, &block : RouteHandler)
    add(route, "", &block)
  end

  def add(route : String, desc : String, &block : RouteHandler)
    pattern = route_to_regex(route)
    @routes.push(Route.new(route, pattern, desc, block))
  end

  def handle(command : String)
    @routes.each do |route|
      result = handle_pattern(command, route.pattern, route.handler)
      break if result
    end
  end

  def routes
    @routes
  end

  private def handle_pattern(command, pattern, cb) : Bool
    m = command.match(pattern)
    return false if m.nil?
    groups = m.named_captures
    nil_groups = groups.select { |_, v| v.nil? }
    return false if nil_groups.size != 0
    params = groups.transform_values { |v| v.to_s }
    cb.call params
    true
  end

  private def route_to_regex(route) : Regex
    Regex.new('^' + split_route route)
  end

  private def split_route(route) : String
    vals = route.partition(/\{[a-z]+?\}/)
    param = vals[1].lstrip('{').rstrip('}')
    result = ""
    if vals[0] != ""
      result += Regex.escape(vals[0])
    end
    if vals[1] != ""
      result += sprintf "(?P<%s>.+?)", param
    end
    if vals[2] != ""
      result += split_route(vals[2])
    end
    result
  end
end
