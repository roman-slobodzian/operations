RSpec.describe Operations::Mounter::JsonRpc::Middleware do
  let(:app) { ->(_env) { [200, {"Content-Type" => "text/plain"}, ["From app"]] } }

  subject do
    described_class.new(app, operation_classes: [operation_class])
  end

  context "POST" do
    context "successful operation" do
      let(:operation_class) do
        Class.new do
          include Operations::Operation

          class_attribute :name, default: "Operations::Post::Create"

          def execute; end

          def normalize
            {name: "Fake name"}
          end
        end
      end

      it "mount and run operation on endpoint" do
        rpc_call("post/create", params: {}, user_token: nil)

        rcp_response_is_expected.to include("result" => {"name" => "Fake name"})
      end
    end
  end

  context "failed operation" do
    context "validation error" do
      let(:operation_class) do
        Class.new do
          include Operations::Operation

          class_attribute :name, default: "Operations::Post::Create"

          def execute; end

          def errors
            {base: "Invalid data"}
          end
        end
      end

      it "mount and run operation on endpoint" do
        rpc_call("post/create", params: {}, user_token: nil)

        rcp_response_is_expected.to include(
          "error" => {
            "code" => 422,
            "message" => "Validation failure",
            "data" => {"base" => "Invalid data"}
          }
        )
      end
    end

    context "exception" do
      let(:operation_class) do
        Class.new do
          include Operations::Operation

          class_attribute :name, default: "Operations::Post::Fetch"

          def execute
            raise "Something bad"
          end
        end
      end

      it "mount and run operation on endpoint" do
        rpc_call("post/fetch", params: {}, user_token: nil)

        rcp_response_is_expected.to include(
          "error" => {
            "code" => -32_603,
            "message" => "Internal error",
            "data" => /Something bad/
          }
        )
      end
    end

    context "method not found" do
      let(:operation_class) do
        Class.new do
          include Operations::Operation

          class_attribute :name, default: "Operations::Post::Fetch"
        end
      end

      it "mount and run operation on endpoint" do
        rpc_call("post/create", params: {}, user_token: nil)

        rcp_response_is_expected.to include(
          "error" => {
            "code" => -32_601,
            "message" => "Method not found",
            "data" => nil
          }
        )
      end
    end

    context "invalid json" do
      let(:operation_class) do
        Class.new do
          include Operations::Operation

          class_attribute :name, default: "Operations::Post::Create"
        end
      end

      it "mount and run operation on endpoint" do
        env = Rack::MockRequest.env_for("/", lint: true, method: "POST")
        status, _, response = subject.call(env)
        body = JSON.parse(response.first)

        expect(status).to eq(200)
        expect(body["error"]).to include(
          "code" => -32_700,
          "data" => nil,
          "message" => "Parse error"
        )
      end
    end
  end

  context "wrong path" do
    let(:operation_class) do
      Class.new do
        include Operations::Operation

        class_attribute :name, default: "Operations::Post::Create"
      end
    end

    it "call app" do
      env = Rack::MockRequest.env_for("/fake", lint: true, method: "POST")
      _, _, response = subject.call(env)

      expect(response).to eq(["From app"])
    end
  end

  def rpc_call(method_name, params = [])
    env = Rack::MockRequest.env_for(
      "/",
      lint: true,
      method: "POST",
      input: {jsonrpc: "2.0", method: method_name, params: params, id: 1}.to_json
    )

    @rpc_response = subject.call(env)
  end

  def rcp_response_is_expected(rpc_response = @rpc_response)
    status, _, response = rpc_response

    expect(status).to eq(200)
    body = JSON.parse(response.first)
    expect(body)
  end
end
