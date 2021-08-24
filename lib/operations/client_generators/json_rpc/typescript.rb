module Operations
  module ClientGenerators
    module JsonRpc
      class TypeScript
        def initialize(operation_classes)
          @operation_classes = operation_classes
        end

        def call
          template = ERB.new(client_template)
          template.result(template_binding)
        end

        private

        attr_reader :operation_classes

        def operation_presenters
          operation_classes.map(&TypeScriptOperationPresenter.method(:new))
        end

        def operation_presenter_groups
          Hash.new { |h, k| h[k] = h.dup.clear }.tap do |groups|
            operation_presenters.map do |operation|
              *namespaces, operation_name = operation.namespace_parts
              namespaces.inject(groups, :[])[operation_name] = operation
            end
          end
        end

        def render_params_and_results(operations = operation_presenter_groups)
          operations.map do |key, value|
            assigment = if value.is_a?(Hash)
              render_params_and_results(value)
            else
              "#{value.render_params_types_export}\n#{value.render_result_types_export}"
            end

            "export namespace #{key} {\n#{assigment}\n}".strip
          end.join("\n")
        end

        def render_call_methods(operations = operation_presenter_groups, level: 0)
          namespace_hash = operations.map do |key, value|
            assigment = if value.is_a?(Hash)
              render_call_methods(value, level: level + 1)
            else
              <<~JS
                (params: #{value.namespace_name}.Params): Promise<#{value.namespace_name}.Result> => {
                   return this.request('#{value.full_name}', params);
                }
              JS
            end

            "#{key.camelize(:lower)}#{level.zero? ? " = " : ": "}#{assigment}".strip
          end.join(level.zero? ? "\n" : ",\n")

          level.zero? ? namespace_hash : "{\n#{namespace_hash}\n}"
        end

        def client_template
          File.read(File.join(Operations.root.to_s, "assets/json_rpc/typescript/client.ts.erb"))
        end

        def template_binding
          binding
        end
      end
    end
  end
end
