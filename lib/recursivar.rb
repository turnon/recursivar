require "recursivar/version"
require "recursivar/tmp_file"
require "recursivar/heap"
require "recursivar/graph"
require "binding_of_callers"

class Object
  def recursivar(**opt)
    Recursivar.new(binding.of_callers, opt).print
  end
end

class Recursivar

  def initialize(stack, opt)
    heap = Heap.new(stack)
    @graph = Graph.new(heap)

    obj = stack.first.send(:binding_self)
    @out = TmpFile.new(obj)
  end

  def print
    @out.puts @graph.to_s
  end

end
