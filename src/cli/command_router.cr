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

  def add(route, &block : RouteHandler)
    pattern = route_to_regex(route)
    @routes.push(Route.new(route, pattern, "", block))
  end

  def add(route, desc, &block : RouteHandler)
    pattern = route_to_regex(route)
    @routes.push(Route.new(route, pattern, desc, block))
  end

  def handle(command)
    @routes.each do |route|
      handle_pattern(command, route.pattern, route.handler)
    end
  end

  def routes
    @routes
  end

  private def handle_pattern(command, pattern, cb)
    m = command.match(pattern)
    return if m.nil?
    groups = m.named_captures
    nil_groups = groups.select { |k, v| v.nil? }
    return if nil_groups.size != 0
    params = groups.transform_values { |v| v.to_s }
    cb.call params
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
