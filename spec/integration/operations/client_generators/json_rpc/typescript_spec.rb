RSpec.describe Operations::ClientGenerators::JsonRpc::TypeScript do
  let(:app) { ->(_env) { [200, {"Content-Type" => "text/plain"}, ["From app"]] } }
  let(:operation_class) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::Create"

      validate do
        params do
          required(:email).maybe(:string)
          optional(:email_2).filled(:string)

          required(:emails).array(:string)
          required(:emails_2).array { str? | int? }
          required(:emails_3) { each { str? } | each { int? } }

          required(:address).hash do
            required(:street).filled(:string)
          end

          required(:addresses).array(:hash) do
            required(:city).filled(:string)
          end
        end
      end

      def execute; end

      def normalize
        {name: "Fake name"}
      end
    end
  end

  subject do
    described_class.new([operation_class])
  end

  it "generates client" do
    # TODO, fix visit_or for arrays (merge "in left or in right")
    # TODO, test in project
    # TODO, handle errors
    # TODO, handle errors
    # TODO, add types for responses

    typescript = subject.call
    puts typescript.to_s
    expect(typescript).to include("export namespace Post.Create")
    expect(typescript).to include("email: null | string")
    expect(typescript).to include("email_2?: string")
    expect(typescript).to include("emails: Array<string>")
    expect(typescript).to include("emails_2: Array<string | number>")
    expect(typescript).to include("emails_3: Array<string> | Array<number>")
    expect(typescript).to match(/address: {\s+street: string\s+}/)
    expect(typescript).to match(/addresses: Array<{\s+city: string\s+}>/)
  end
end
