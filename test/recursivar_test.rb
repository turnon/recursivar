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
testing (RecursivarTest::A)
├─@b (RecursivarTest::A::B)
│ └─@itself (RecursivarTest::A::B) # > @b
├─@c (RecursivarTest::A::C)
│ └─@parent (RecursivarTest::A) #
├─@d (RecursivarTest::A::D)
│ ├─@sibling (RecursivarTest::A::B) # > @b
│ └─@deep (RecursivarTest::A::D::Deep)
│   └─@deep (Integer)
├─@e (RecursivarTest::A::E)
│ └─@cousin (Integer) # > @d > @deep > @deep
└─@m (Module)
EOS

  def setup
    @a = A.new
    @sio = StringIO.new
  end

  def test_match
    rt = @a.recursivar(out: @sio, name: :testing, color: false, format: :tree_graph)
    @sio.rewind

    assert_equal ReturnValue, @sio.read
  end

  def test_tree_graph
    @a.recursivar(out: STDOUT, format: :tree_graph)
  end

  def test_tree_html
    @a.recursivar
  end
end
