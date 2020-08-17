require "tree_graph"
require "tree_html"
require "cgi"

class Recursivar
  module Formats

    include TreeGraph

    def label_for_tree_graph
      label = "#{name} (#{obj.class})"
      return label unless ref
      "#{label} #{ref.location_str}"
    end

    def children_for_tree_graph
      vars
    end

    module Color
      def label_for_tree_graph
        label = "#{colorize name} (#{klass})"
        return label unless ref
        "#{label} #{colorize ref.location_str}"
      end

      private

      def colorize(str)
        "\e[1m\e[32m#{str}\e[0m"
      end
    end

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
  end
end
