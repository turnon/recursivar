require "recursivar/version"
require "tree_graph"

class Object
  def recursivar(**opt)
    Recursivar.new(self, opt).print
  end
end

class Recursivar

  class Var
    attr_reader :name, :obj, :ref, :vars

    def initialize(name, obj, seen)
      @name = name
      @obj = obj
      @vars = []

      obj_id = obj.object_id
      return if @ref = seen[obj_id]
      seen[obj_id] = self

      obj.instance_variables.map do |name|
        value = obj.instance_variable_get(name)
        @vars << Var.new(name, value, seen)
      end
    end

    include TreeGraph

    def label_for_tree_graph
      "#{name} (#{obj.class})"
    end

    def children_for_tree_graph
      vars
    end
  end

  attr_reader :start

  def initialize(obj, out: STDOUT, name: nil)
    name ||= "#<#{obj.class}:#{obj.object_id}>"
    @start = Var.new(name, obj, {})
    @out = out
  end

  def print
    @out.puts start.tree_graph
  end
end
