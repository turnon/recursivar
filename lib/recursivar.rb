require "recursivar/version"
require "tree_graph"

class Object
  def recursivar(**opt)
    Recursivar.new(self, opt).print
  end
end

class Recursivar

  class Var
    attr_reader :name, :obj, :ref, :vars, :location

    def initialize(name, obj, path, seen)
      @name = name
      @obj = obj
      @vars = []
      @location = (path << name)

      obj_id = obj.object_id
      return if @ref = seen[obj_id]
      seen[obj_id] = self

      klass = self.class
      obj.instance_variables.map do |name|
        value = obj.instance_variable_get(name)
        @vars << klass.new(name, value, location.dup, seen)
      end
    end

    def label
      "#{name} (#{obj.class})"
    end

    def location_str
      location.join(' > ')
    end

    include TreeGraph

    def label_for_tree_graph
      return label unless ref
      "#{label} => #{ref.location_str}"
    end

    def children_for_tree_graph
      vars
    end
  end

  module Color
    def label
      "#{colorize name} (#{obj.class})"
    end

    def location_str
      colorize super
    end

    private

    def colorize(str)
      "\e[1m\e[32m#{str}\e[0m"
    end
  end

  attr_reader :start

  def initialize(obj, out: STDOUT, name: nil, color: true)
    name ||= "#<#{obj.object_id}>"

    var_klass = Var.clone
    var_klass = var_klass.prepend Color if color

    @start = var_klass.new(name, obj, [], {})
    @out = out
  end

  def print
    @out.puts start.tree_graph
  end
end
