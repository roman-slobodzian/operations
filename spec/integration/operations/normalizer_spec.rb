class Presenter
  include Operations::Normalizer

  field :first_name, :string
  field :last_name, :string

  embed :company do
    field :title, :string

    embed :location do
      field :city, :string
      field :state, :string
    end

    embed :founding do
      field :year, :number
    end
  end

  embed :addresses, collection: true do
    field :city, :string
    field :state, :string
  end
end

RSpec.describe Operations::Normalizer do
  describe "#schema" do
    it "should handle a basic presenter" do
      parsed = Presenter.schema

      expect(parsed).to match_array([
        have_attributes(path: :first_name, type: :string),
        have_attributes(path: :last_name, type: :string),
        have_attributes(
          path: :addresses,
          type: :hash,
          collection: true,
          schema: match_array([
            have_attributes(path: :city, type: :string),
            have_attributes(path: :state, type: :string)
          ])
        ),
        have_attributes(
          path: :company,
          type: :hash,
          collection: false,
          schema: match_array([
            have_attributes(
              path: :title,
              type: :string
            ),
            have_attributes(
              path: :location,
              type: :hash,
              collection: false,
              schema: match_array([
                have_attributes(path: :city, type: :string),
                have_attributes(path: :state, type: :string)
              ])
            ),
            have_attributes(
              path: :founding,
              type: :hash,
              collection: false,
              schema: match_array([
                have_attributes(path: :year, type: :number)
              ])
            )
          ])
        )
      ])
    end
  end

  describe "#normalize" do
    let(:current_user) do
      OpenStruct.new
    end

    let(:model_data) do
      {
        first_name: "Jhon",
        last_name: "Brown",

        company: OpenStruct.new(
          title: "Company",
          location: OpenStruct.new(
            city: "Denver",
            state: "Colorado"
          ),

          founding: OpenStruct.new(year: 2002)
        )
      }
    end

    let(:model) do
      OpenStruct.new(model_data)
    end

    let(:model_2_data) do
      {
        first_name: "Tom",
        last_name: "Fox",

        addresses: [
          OpenStruct.new(
            city: "Denver",
            state: "Colorado"
          ),
          OpenStruct.new(
            city: "New York",
            state: "New York"
          )
        ]
      }
    end

    let(:model_2) do
      OpenStruct.new(model_2_data)
    end

    context "single model" do
      let(:presenter) do
        Presenter.new(model)
      end

      it "should present data" do
        expect(presenter.normalize).to eq(
          first_name: "Jhon",
          last_name: "Brown",
          addresses: nil,

          company: {
            title: "Company",
            location: {
              city: "Denver",
              state: "Colorado"
            },

            founding: {
              year: 2002
            }
          }
        )
      end
    end

    context "collection of models" do
      let(:models_list) { [model, model_2] }

      it "should present data" do
        expect(Presenter.normalize(models_list)).to match_array([
          {
            first_name: "Jhon",
            last_name: "Brown",
            addresses: nil,

            company: {
              title: "Company",
              location: {
                city: "Denver",
                state: "Colorado"
              },

              founding: {
                year: 2002
              }
            }
          }, {
            first_name: "Tom",
            last_name: "Fox",
            company: nil,

            addresses: [
              {
                city: "Denver",
                state: "Colorado"
              }, {
                city: "New York",
                state: "New York"
              }
            ]
          }
        ])
      end
    end
  end
end
