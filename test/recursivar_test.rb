require "test_helper"

class RecursivarTest < Minitest::Test

  class A
    def initialize
      @b = B.new
      @c = C.new
      @m = M
    end

    class B
      def initialize
        @itself = self
      end
    end
  end

  class C; end

  module M; end

  ReturnValue = <<EOS
testing (RecursivarTest::A)
├─@b (RecursivarTest::A::B)
│ └─@itself (RecursivarTest::A::B)
├─@c (RecursivarTest::C)
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
