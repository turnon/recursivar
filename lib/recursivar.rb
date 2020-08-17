require "recursivar/version"
require "recursivar/tmp_file"
require "tree_graph"
require "tree_html"
require "cgi"

class Object
  def recursivar(**opt)
    Recursivar.new(self, opt).print
  end
end

class Recursivar

  class Var
    attr_reader :name, :obj, :ref, :vars, :location

    def initialize(name, obj, loc, seen)
      @name = name
      @obj = obj
      @vars = []
      @location = loc

      obj_id = obj.object_id
      return if @ref = seen[obj_id]
      seen[obj_id] = self

      klass = self.class
      obj.instance_variables.map do |name|
        value = obj.instance_variable_get(name)
        place = (location.dup << name)
        @vars << klass.new(name, value, place, seen)
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
      "#{label} #{ref.location_str}"
    end

    def children_for_tree_graph
      vars
    end

    include TreeHtml

    def label_for_tree_html
      lab = "<span class='highlight'>#{name}</span> #{obj.class}"
      return lab unless ref
      "#{lab} <span class='highlight'>#{CGI::escapeHTML ref.location_str}</span>"
    end

    def children_for_tree_html
      vars
    end

    def css_for_tree_html
      '.highlight{color: #a50000;}'
    end
  end

  module Color
    def label_for_tree_graph
      lab = "#{colorize name} (#{obj.class})"
      return lab unless ref
      "#{lab} #{colorize ref.location_str}"
    end

    private

    def colorize(str)
      "\e[1m\e[32m#{str}\e[0m"
    end
  end

  attr_reader :start

  def initialize(obj, out: false, name: nil, color: true, format: :tree_html_full)
    name ||= "#<#{obj.object_id}>"

    var_klass = Var.clone
    var_klass = var_klass.prepend Color if color

    @start = var_klass.new(name, obj, ['#'], {})
    @out = out || TmpFile.new(obj, format)
    @format = format
  end

  def print
    @out.puts start.send(@format)
  end

end
