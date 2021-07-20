RSpec.describe Operations::Validation do
  let(:operation_class) do
    Class.new(Operations::Operation) do
      validate do
        params do
          required(:email).filled(:string)
        end
      end
    end
  end

  subject { operation_class.new(params: params) }

  context "valid input" do
    let(:params) do
      {
        email: "email@example.com"
      }
    end

    it "run execute method and operation has no errors" do
      is_expected.to receive(:execute)

      subject.call

      expect(subject[:errors]).to eq({})
    end
  end

  context "invalid input" do
    let(:params) do
      {
        email: ""
      }
    end

    it "do not execute method and operation has errors" do
      is_expected.to_not receive(:execute)

      subject.call

      expect(subject[:errors]).to match(
        email: ["must be filled"]
      )
    end
  end
end
