describe Frenetic::Configuration do
  let(:content_type) { 'application/vnd.frenetic-v1-hal+json' }
  let(:yaml_config) {
    { 'test' => {
        'url'          => 'http://example.org',
        'api_key'      => '1234567890',
        'headers' => {
          'accept' => content_type,
        },
        'response' => {
          'use_logger' => true
        },
        'request' => {
          'timeout' => 10000
        }
      }
    }
  }
  let(:config) { Frenetic::Configuration.new( unknown: :option ) }

  subject { config }

  describe ".configuration" do
    include FakeFS::SpecHelpers

    context "with a proper config YAML" do
      before do
        FileUtils.mkdir_p("config")
        File.open( 'config/frenetic.yml', 'w') do |f|
          f.write( YAML::dump(yaml_config) )
        end
      end

      it { should include(:username) }
      it { should include(:url) }

      it { should_not include(:unknown => 'option')}

      it "should set default response options" do
        subject[:response][:use_logger].should == true
      end

      it "should set default request options" do
        subject[:request][:timeout].should == 10000
      end

      it "should set a User Agent request header" do
        subject[:headers][:user_agent].should =~ %r{Frenetic v.+; \S+$}
      end

      context "with a specified Accept header" do
        it "should set an Accept request header" do
          subject[:headers].should include(:accept => 'application/vnd.frenetic-v1-hal+json')
        end
      end
      context "without a specified Accept header" do
        let(:content_type) { nil }

        it "should set an Accept request header" do
          subject[:headers].should include(:accept => 'application/hal+json')
        end
      end
    end

    context "with no config YAML" do
      context "and no passed options" do
        it "should raise a configuration error" do
          expect { Frenetic::Configuration.new }.to raise_error( Frenetic::Configuration::ConfigurationError )
        end
      end
      context "and passed options" do
        let(:config) { Frenetic::Configuration.new( 'url' => 'http://example.org' ) }

        it { should be_a( Hash ) }
        it { should_not be_empty }
        it "should set an Accepts request header" do
          subject[:headers].should include(:accept => 'application/hal+json')
        end
        it "should set a User Agent request header" do
          subject[:headers][:user_agent].should =~ %r{Frenetic v.+; \S+$}
        end

        context "which includes incorrect cache settings" do
          before { Frenetic::Configuration.any_instance.stubs(:configure_cache).returns(nil) }

          it "should raise a configuration error for a missing :metastore" do
            expect {
              Frenetic::Configuration.new('url' => 'http://example.org', 'cache' => {} )
            }.to raise_error(
              Frenetic::Configuration::ConfigurationError, "No cache :metastore defined!"
            )
          end

          it "should raise a configuration error for a missing :entitystore" do
            expect {
              Frenetic::Configuration.new('url' => 'http://example.org', 'cache' => { 'metastore' => 'foo' } )
            }.to raise_error(
              Frenetic::Configuration::ConfigurationError, "No cache :entitystore defined!"
            )
          end

          it "should raise a configuration error for missing required header filters" do
            cache_cfg = {
              'metastore'      => 'foo',
              'entitystore'    => 'bar',
              'ignore_headers' => ['baz'] # `configure_cache` method is skipped to create a bad state
            }

            expect {
              Frenetic::Configuration.new('url' => 'http://example.org', 'cache' => cache_cfg )
            }.to raise_error(
              Frenetic::Configuration::ConfigurationError, "Required cache header filters are missing!"
            )
          end
        end
      end
    end
  end

end