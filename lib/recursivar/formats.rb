require "tree_graph"
require "tree_html"
require "cgi"
require "macrocosm"

class Recursivar
  module Formats

    module TextWithoutColor
      include TreeGraph

      def label_for_tree_graph
        label = "#{name} (#{obj.class})"
        return label unless ref
        "#{label} #{ref.location_str}"
      end

      def children_for_tree_graph
        vars
      end

      def to_s
        tree_graph
      end
    end

    module Text
      include TreeGraph

      def label_for_tree_graph
        label = "#{colorize name} (#{klass})"
        return label unless ref
        "#{label} #{colorize ref.location_str}"
      end

      def children_for_tree_graph
        vars
      end

      def to_s
        tree_graph
      end

      private

      def colorize(str)
        "\e[1m\e[32m#{str}\e[0m"
      end
    end

    module Html
      include TreeHtml

      def label_for_tree_html
        label = "<span class='highlight'>#{name}</span> #{klass}"
        return label unless ref
        "#{label} <span class='highlight'>#{CGI::escapeHTML ref.location_str}</span>"
      end

      def children_for_tree_html
        vars
      end

      def css_for_tree_html
        '.highlight{color: #a50000;}'
      end

      def to_s
        tree_html_full
      end
    end

    module Graph
      def each_nodes(&block)
        block.call(label)
        vars.each do |v|
          v.each_nodes(&block) unless v.ref
        end
      end

      def each_links(&block)
        vars.each do |v|
          block.call(label, v.name, v.label)
          v.each_links(&block)
        end
      end

      def label
        "#<#{klass}:#{obj.object_id}>"
      end

      def to_s
        g = Macrocosm.new

        each_nodes do |n|
          g.add_node(n ,n)
        end

        each_links do |n1, var_name, n2|
          g.add_link(n1, n2, relation_in_list: var_name, relation_in_graph: var_name)
        end

        g.to_s
      end
    end

  end
end
