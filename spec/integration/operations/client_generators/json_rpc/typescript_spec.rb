RSpec.describe Operations::ClientGenerators::JsonRpc::TypeScript do
  let(:app) { ->(_env) { [200, {"Content-Type" => "text/plain"}, ["From app"]] } }
  let(:operation_class) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::Create"

      normalizer PostNormalizer

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

  let(:nested_operation_class) do
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

  let(:list_operation_class) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::List"

      normalizer PostNormalizer, collection: true

      def execute; end
    end
  end

  let(:scalar_operation_class) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::Count"

      normalizer :number

      def execute; end
    end
  end

  let(:scalars_operation_class) do
    Class.new(Operations::Operation) do
      class_attribute :name, default: "Operations::Post::IdsList"

      normalizer :number, collection: true

      def execute; end
    end
  end

  subject do
    described_class.new([operation_class, list_operation_class, scalar_operation_class, scalars_operation_class,
                         nested_operation_class])
  end

  before do
    stub_const("PostNormalizer", Class.new do
      include Operations::Normalizer

      field :first_name, :string
      field :last_name, :string, null: true

      embed :company do
        field :title, :string
      end

      embed :companies, collection: true do
        field :title, :string
      end
    end)
  end

  it "generates client" do
    typescript = subject.call
    puts typescript.to_s

    # Dry schema
    expect(typescript).to include("export namespace Post {")
    expect(typescript).to include("export namespace Create {")
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

    # Collection
    expect(typescript).to include("export type Result = Array<{")

    # Scalars
    expect(typescript).to include("export type Result = number")
    expect(typescript).to include("export type Result = Array<number>")

    # Call methods
    expect(typescript).to match(%r{post = \{\
\s+create: \(params: Post\.Create\.Params\): Promise<Post\.Create\.Result> => \{\
\s+return this\.request\('post/create', params\);\s+\
\},\
\s+list: \(params: Post\.List\.Params\): Promise<Post\.List\.Result> => \{\
\s+return this\.request\('post/list', params\);\s+\
\},\
\s+count: \(params: Post\.Count\.Params\): Promise<Post\.Count\.Result> => \{\
\s+return this\.request\('post/count', params\);\s+\
\},\
\s+idsList: \(params: Post\.IdsList\.Params\): Promise<Post\.IdsList\.Result> => \{\
\s+return this\.request\('post/ids_list', params\);\s+\
\},\
\s+comment: \{\
\s+delete: \(params: Post\.Comment\.Delete\.Params\): Promise<Post\.Comment\.Delete\.Result> => \{\
\s+return this\.request\('post/comment/delete', params\);\
\s+\}\
\s+\}\
\s+\}})
  end
end
