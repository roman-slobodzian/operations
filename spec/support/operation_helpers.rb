module OperationHelpers
  def build_operation_class(class_name = nil, &block)
    klass = Class.new(Operations::Operation) do
      class_attribute :name, default: class_name
    end

    klass.tap do |k|
      k.instance_eval(&block) if block
    end
  end
end
