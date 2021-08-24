RSpec.describe Operations::Operation do
  describe "detect normalizer class" do
    context "set normalizer" do
      subject do
        Class.new(described_class) do
          normalizer CustomNormalizer
        end
      end

      before do
        stub_const("CustomNormalizer", Class.new)
      end

      it { is_expected.to have_attributes(defined_normalizer: CustomNormalizer) }
    end

    context "set false as normalizer" do
      subject do
        Class.new(described_class) do
          normalizer false
        end
      end

      it { is_expected.to have_attributes(defined_normalizer: false) }
    end

    context "by resource class name" do
      subject do
        Class.new(described_class) do
          def self.name
            "Posts::Create"
          end
        end
      end

      before do
        stub_const("Post", Class.new)
        stub_const("PostNormalizer", Class.new do
          include Operations::Normalizer
        end)
      end

      it { is_expected.to have_attributes(defined_normalizer: PostNormalizer) }
    end

    context "when no presenter found" do
      subject do
        Class.new(described_class) do
          def self.name
            "FakeClass::Create"
          end
        end
      end

      it { is_expected.to have_attributes(defined_normalizer: nil) }
    end
  end

  describe "normalize" do
    subject do
      Class.new(described_class) do
        normalizer PostNormalizer

        def execute
          2.times.map do |n|
            OpenStruct.new(title: "Post #{n}", description: "Description")
          end
        end
      end.new.call
    end

    before do
      stub_const("PostNormalizer", Class.new do
        include Operations::Normalizer

        field :title, :string
      end)
    end

    it do
      expect(subject.normalize).to eq([
        {title: "Post 0"},
        {title: "Post 1"}
      ])
    end
  end
end
