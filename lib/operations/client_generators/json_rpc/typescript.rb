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
