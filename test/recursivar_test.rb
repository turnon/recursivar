require "test_helper"

class RecursivarTest < Minitest::Test

  class A
    def initialize
      @b = B.new
      @c = C.new(self)
      @d = D.new(@b)
      @e = E.new(@d.deep)
      @m = M
    end

    class B
      def initialize
        @itself = self
      end
    end

    class C
      def initialize(parent)
        @parent = parent
      end
    end

    class D
      def initialize(sibling)
        @sibling = sibling
        @deep = Deep.new
      end

      def deep
        @deep.deep
      end

      class Deep
        attr_reader :deep
        def initialize
          @deep = 123
        end
      end
    end

    class E
      def initialize(cousin)
        @cousin = cousin
      end
    end

    module M; end
  end


  def test_macrocosm
    a = A.new
    a.recursivar
  end
end
