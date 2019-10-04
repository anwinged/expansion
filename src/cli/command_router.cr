class CLI::CommandRouter
  def initialize
    @mappings = [] of {Regex, Proc(Hash(String, String), Nil)}
  end

  def add(route, &block : Hash(String, String) -> Nil)
    pattern = route_to_regex(route)
    @mappings.push({pattern, block})
  end

  def handle(command)
    @mappings.each do |handler|
      handle_pattern(command, *handler)
    end
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
      result += route_to_regex(vals[2]).source
    end
    Regex.new(result)
  end
end
