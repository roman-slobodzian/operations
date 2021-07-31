module Operations
  module ClientGenerators
    module JsonRpc
      class TypeScriptOperationPresenter
        def initialize(operation_class)
          @operation_class = operation_class
        end

        def namespace_name
          operation_class.name.match(/(Operations::)?(.+)$/)[2].gsub("::", ".")
        end

        def render_params_types
          compiler = Operations::DrySchemaCompiler.new
          compiler.call(operation_class.validation_contract.schema.to_ast)
          compiler.keys

          TypeScriptTypeRenderer.new.call({type: :hash, member: compiler.keys})
        end

        def render_result_types
          compiler = Operations::NormalizerSchemaCompiler.new(operation_class.normalizer_class)

          TypeScriptTypeRenderer.new.call({type: :hash, member: compiler.call})
        end

        private

        attr_reader :operation_class
      end
    end
  end
end
