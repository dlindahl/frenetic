describe Frenetic::HalJson do
  let(:hal_json) { Frenetic::HalJson.new }
  let(:app_callbacks_stub) do
    stub('FaradayCallbackStubs').tap do |cb_stub|
      cb_stub.stubs('on_complete').yields env
    end
  end
  let(:app_stub) do
    stub('FaradayAppStub').tap do |app_stub|
      app_stub.stubs(call: app_callbacks_stub)
    end
  end

  before { hal_json.instance_variable_set("@app", app_stub) }

  subject { hal_json }

  describe "#call" do
    let(:env) { Hash.new(:status => 200) }

    before do
      hal_json.stubs(:on_complete)

      hal_json.call(env)
    end

    it "should execute the on_complete callback" do
      hal_json.should have_received(:on_complete).with(env)
    end
  end

  describe "#on_complete" do
    context "with a successful response" do
      let(:env) do
        {
          :status => 200,
          :body => JSON.generate({
            '_links' => {}
          })
        }
      end

      before { hal_json.on_complete(env) }

      it "should parse the HAL+JSON response" do
        env[:body].should be_a( Frenetic::HalJson::ResponseWrapper )
      end
    end    
  end

  describe "#success?" do
    subject { hal_json.success?( env ) }

    context "with a 200 OK response" do
      let(:env) { {:status => 200 } }

      it { should be_true }
    end
    context "with a 201 Created response" do
      let(:env) { {:status => 201 } }

      it { should be_true }
    end
    context "with a 204 No Content" do
      let(:env) { {:status => 204 } }

      it { should be_false }
    end
  end
end