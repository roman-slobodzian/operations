class Presenter
  include Operations::Normalizer

  field :first_name
  field :last_name

  embed :company do
    field :title

    embed :location do
      field :city
      field :state
    end

    embed :founding do
      field :year
    end
  end

  embed :addresses do
    field :city
    field :state
  end
end

RSpec.describe Operations::Normalizer do
  describe "#schema" do
    it "should handle a basic presenter" do
      parsed = Presenter.schema

      expect(parsed).to match_array([
        have_attributes(path: :first_name),
        have_attributes(path: :last_name),
        have_attributes(
          path: :addresses,
          schema: match_array([
            have_attributes(path: :city),
            have_attributes(path: :state)
          ])
        ),
        have_attributes(
          path: :company,
          schema: match_array([
            have_attributes(
              path: :title
            ),
            have_attributes(
              path: :location,
              schema: match_array([
                have_attributes(path: :city),
                have_attributes(path: :state)
              ])
            ),
            have_attributes(
              path: :founding,
              schema: match_array([
                have_attributes(path: :year)
              ])
            )
          ])
        )
      ])
    end
  end

  describe "#represent" do
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

    let(:model2_data) do
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

    let(:model2) do
      OpenStruct.new(model2_data)
    end

    context "single model" do
      let(:presenter) do
        Presenter.new(model)
      end

      it "should present data" do
        expect(presenter.represent).to eq(
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
      let(:models_list) { [model, model2] }

      it "should present data" do
        expect(Presenter.represent(models_list)).to match_array([
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