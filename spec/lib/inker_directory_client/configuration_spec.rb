describe InkerDirectoryClient::Configuration do
  let(:yaml_config) {
    { 'test' => {
        'url'     => 'http://example.org',
        'api_key' => '1234567890',
        'version' => 'v2'
      }
    }
  }
  let(:config) { InkerDirectoryClient::Configuration.new( unknown: :option ) }

  subject { config }

  describe ".configuration" do
    include FakeFS::SpecHelpers

    context "with a proper config YAML" do
      before do
        FileUtils.mkdir_p("config")
        File.open( 'config/inker_directory_client.yml', 'w') do |f|
          f.write( YAML::dump(yaml_config) )
        end
      end

      it { should include(:user) }
      it { should include(:accepts) }
      it { should include(:url) }
      it { should_not include(:unknown => 'option')}
    end

    context "with no config YAML" do
      it { should be_a( Hash ) }
      it { should be_empty }
    end
  end

end