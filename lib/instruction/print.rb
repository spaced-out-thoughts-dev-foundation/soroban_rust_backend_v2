# frozen_string_literal: true

module SorobanRustBackend
  module Instruction
    # This class is responsible for generating Rust code for the LogString instruction.
    class Print < Handler
      def handle
        "log!(#{inputs_to_rust_string(@instruction.inputs)});"
      end

      private

      def inputs_to_rust_string(inputs)
        inputs.map { |input| ref_appender(input) }.join(', ')
      end

      def ref_appender(input)
        input
        # decorated_input = Common::InputInterpreter.interpret(input)

        # if decorated_input[:needs_reference] && decorated_input[:value] == 'env'
        #   "&#{decorated_input[:value]}"
        # else
        #   decorated_input[:value]
        # end
      end
    end
  end
end
