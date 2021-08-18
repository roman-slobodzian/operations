RSpec.describe Operations::NormalizerSchemaCompiler do
  let(:presenter_class) do
    Class.new do
      include Operations::Normalizer

      field :first_name, :string
      field :last_name, :string, null: true

      embed :company do
        field :title, :string

        embed :location do
          field :state, :string
        end
      end

      embed :addresses, collection: true do
        field :city, :string
      end
    end
  end

  describe "#call" do
    subject { described_class.new(presenter_class).call }

    it "should handle a basic presenter" do
      expect(subject).to eq(
        type: :hash,
        member: {
          first_name: {required: true, type: [type: :string]},
          last_name: {required: false, type: [type: :string]},
          company: {
            required: true,
            type: [
              type: :hash,
              member: {
                title: {required: true, type: [type: :string]},
                location: {
                  required: true,
                  type: [
                    type: :hash,
                    member: {
                      state: {required: true, type: [type: :string]}
                    }
                  ]
                }
              }
            ]
          },
          addresses: {
            required: true,
            type: [
              type: :array,
              member: [
                type: :hash,
                member: {
                  city: {required: true, type: [type: :string]}
                }
              ]
            ]
          }
        }
      )
    end
  end
end
