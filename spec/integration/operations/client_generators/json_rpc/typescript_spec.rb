class PostNormalizer
  include Operations::Normalizer

  field :first_name, :string
  field :last_name, :string, null: true

  embed :company do
    field :title, :string
  end

  embed :companies, collection: true do
    field :title, :string
  end
end

RSpec.describe Operations::ClientGenerators::JsonRpc::TypeScript do
  let(:app) { ->(_env) { [200, {"Content-Type" => "text/plain"}, ["From app"]] } }
  let(:operation_class) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::Create"

      normalizer_class! PostNormalizer

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
    end
  end

  let(:operation_class_2) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::Comment::Delete"

      validate do
        params do
          required(:comment_id).filled(:int?)
        end
      end

      def execute; end
    end
  end

  subject do
    described_class.new([operation_class, operation_class_2])
  end

  it "generates client" do
    # TODO, test in project
    # TODO, handle errors
    # TODO, handle errors

    typescript = subject.call
    puts typescript.to_s

    # Dry schema
    expect(typescript).to include("export namespace Post.Create")
    expect(typescript).to include("email: null | string")
    expect(typescript).to include("email_2?: string")
    expect(typescript).to include("emails: Array<string>")
    expect(typescript).to include("emails_2: Array<string | number>")
    expect(typescript).to include("emails_3: Array<string> | Array<number>")
    expect(typescript).to match(/address: {\s+street: string\s+}/)
    expect(typescript).to match(/addresses: Array<{\s+city: string\s+}>/)

    # Normalizer schema
    expect(typescript).to include("first_name: string")
    expect(typescript).to include("last_name?: string")
    expect(typescript).to match(/company: {\s+title: string\s+}/)
    expect(typescript).to match(/companies: Array<{\s+title: string\s+}>/)

    # Void normalizer schema
    expect(typescript).to include("export type Result = void")

    # Call methods
    expect(typescript).to match(%r{post = \{\
\s+create: \(params: Post\.Create\.Params\): Promise<Post\.Create\.Result> => \{\
\s+return this\.request\('post/create', params\);\s+\
\},\
\s+comment: \{\
\s+delete: \(params: Post\.Comment\.Delete\.Params\): Promise<Post\.Comment\.Delete\.Result> => \{\
\s+return this\.request\('post/comment/delete', params\);\s+\}\s+\}\s+\}})
  end
end
