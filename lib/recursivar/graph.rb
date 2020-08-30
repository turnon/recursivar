require "macrocosm"

class Recursivar

  class Graph
    attr_reader :heap

    def initialize(heap)
      @graph = Macrocosm.new(curveness: 0.2)

      heap.each do |var|
        @graph.add_node(var.inspect, var.klass)

        var.values.each_pair do |name, ref_var|
          @graph.add_link(var.inspect, ref_var.inspect, relation_in_list: name, relation_in_graph: name)
        end

        var.callees && var.callees.each_pair do |level, callee|
          level = "-#{level}"
          @graph.add_link(var.inspect, callee.inspect, relation_in_list: level, relation_in_graph: level, line_style: {type: :dotted})
        end
      end
    end

    def to_s
      @graph.to_s
    end

  end

end
