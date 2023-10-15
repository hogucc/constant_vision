# frozen_string_literal: true

require_relative '../../../../lib/constant_vision'

module RuboCop
  module Cop
    module CustomCops
      class ConstantVisionCop < Cop
        def on_const(node)
          constant_name = node.children[1].to_s
          namespace_nodes = find_namespace_nodes(node)
          nodes = nodes_to_s(namespace_nodes)
          namespace_path = if nodes.empty?
            'Object'
          else
            nodes
          end

          origin = ConstantVision.find_origin_of_constant(constant_name, namespace_path)
          return if origin.nil?

          candidates = ConstantVision.find_constant(constant_name)
          message = "Origin: #{origin}\nCandidates: #{candidates.join(', ')}"
          add_offense(node, message: message)
        end

        def nodes_to_s(nodes)
          nodes.map { |node| node.children[0].children[1] }.reverse.join("::")
        end

        def find_namespace_nodes(node)
          return [] unless node.parent

          if (node.parent.type == :module || node.parent.type == :class) && node.parent.children[1] == node
            [node.parent] + find_namespace_nodes(node.parent)
          else
            find_namespace_nodes(node.parent)
          end
        end
      end
    end
  end
end
