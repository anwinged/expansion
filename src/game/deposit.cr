module Game
  class Deposit
    class Span
      def initialize(@res : Resources::Type, @cap : Capacity)
      end

      getter res
      getter cap
    end

    @cur : Capacity = 0

    def initialize(@res : Resources::Type, @cap : Capacity)
      @cur = @cap
    end

    def initialize(@res : Resources::Type, @cap : Capacity, @cur : Capacity)
    end

    getter res
    getter cap
    getter cur

    def inc(span : Span)
      check_res span.res
      @cur = Math.min(@cap, @cur + span.cap)
    end

    def dec(span : Span)
      check_res span.res
      @cur = Math.max(0, @cur - span.cap)
    end

    private def check_res(other_res : Resources::Type)
      if @res != other_res
        raise ResourceMismatch.new
      end
    end
  end
end
