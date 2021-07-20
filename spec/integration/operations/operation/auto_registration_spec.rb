RSpec.describe Operations::Operation::AutoRegistration do
  let!(:auto_registrable_operation) do
    Class.new(Operations::Operation) do
      def self.name
        "AutoRegistrableOperation"
      end

      include Operations::Operation::AutoRegistration
    end
  end

  let!(:operation_class_1) do
    Class.new(auto_registrable_operation)
  end

  let!(:operation_class_2) do
    Class.new(auto_registrable_operation)
  end

  let!(:operation_class_3) do
    Class.new(Operations::Operation)
  end

  it "operation is registered" do
    expect(auto_registrable_operation).to have_attributes(operations: [operation_class_1, operation_class_2])
  end
end
