module Operations
  module ClientGenerators
    module JsonRpc
      class TypeScriptOperationPresenter
        delegate :defined_normalizer, :validation_contract, to: :operation_class

        def initialize(operation_class)
          @operation_class = operation_class
        end

        def namespace_name
          operation_class.name.match(/(Operations::)?(.+)$/)[2].gsub("::", ".")
        end

        def full_name
          @full_name ||= Operations::Mounter::JsonRpc::Middleware.operation_name(operation_class)
        end

        def namespace_parts
          @namespace_parts ||= operation_class.name.match(/(Operations::)?(.+)$/)[2].split("::")
        end

        def render_params_types
          compiler = Operations::DrySchemaCompiler.new
          compiler.call(operation_class.validation_contract.schema.to_ast)
          compiler.keys

          TypeScriptTypeRenderer.new.call({types: [{type: :hash, member: compiler.keys}]})
        end

        def render_result_types
          compiler = Operations::NormalizerSchemaCompiler.new(
            operation_class.defined_normalizer,
            collection: operation_class.collection?
          )

          TypeScriptTypeRenderer.new.call(compiler.call)
        end

        def render_params_types_export
          if operation_class.validation_contract
            "export type Params = #{render_params_types}"
          else
            "export type Params = void"
          end
        end

        def render_result_types_export
          if operation_class.defined_normalizer
            "export type Result = #{render_result_types}"
          else
            "export type Result = void"
          end
        end

        private

        attr_reader :operation_class
      end
    end
  end
end
