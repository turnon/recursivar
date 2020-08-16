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

  ReturnValue = <<EOS
testing
├─@b (RecursivarTest::A::B)
│ └─@itself (RecursivarTest::A::B)
├─@c (RecursivarTest::A::C)
│ └─@parent (RecursivarTest::A)
├─@d (RecursivarTest::A::D)
│ ├─@sibling (RecursivarTest::A::B)
│ └─@deep (RecursivarTest::A::D::Deep)
│   └─@deep (Integer)
├─@e (RecursivarTest::A::E)
│ └─@cousin (Integer)
└─@m (Module)
EOS

  def setup
    @a = A.new
    @sio = StringIO.new
  end

  def test_trace_tree
    rt = @a.recursivar(out: @sio, name: :testing)
    @sio.rewind

    assert_equal ReturnValue, @sio.read
  end
end
