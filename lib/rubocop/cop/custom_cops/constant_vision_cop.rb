# frozen_string_literal: true

require_relative '../../../../lib/constant_vision'

module RuboCop
  module Cop
    module CustomCops
      class ConstantVisionCop < Cop
        def on_const(node)
          constant_name = node.children[1].to_s
          origin = ConstantVision.find_origin_of_constant(constant_name, Object)
          candidates = ConstantVision.find_constant(constant_name)
          message = "Origin: #{origin}\nCandidates: #{candidates.join(', ')}"
          add_offense(node, message: message)
        end
      end
    end
  end
end
