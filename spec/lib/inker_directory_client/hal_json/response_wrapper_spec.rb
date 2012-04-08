describe InkerDirectoryClient::HalJson::ResponseWrapper do
  let(:properties) do
    { 'a' => 1, 'b' => 2 }
  end
  let(:wrapper) { InkerDirectoryClient::HalJson::ResponseWrapper.new( properties ) }

  subject { wrapper }

  describe "#members" do
    subject { wrapper.members }

    its(:size) { should == 2 }
    its(:first) { should == 'a' }
    its(:last) { should == 'b' }
  end

  describe "#each" do
    before do
      @items = []
      wrapper.each do |*args|
        @items << args
      end
    end

    it { should be_a InkerDirectoryClient::HalJson::ResponseWrapper }
    it "should iterate over each getter" do
      @items.should == [ ['a',1], ['b',2] ]
    end
  end

  describe ".define_setter" do
    subject { wrapper.methods(false) }

    it "should not create setters" do
      subject.none? { |name| name.to_s =~ %r{=} }.should be_true
    end
  end

  describe ".define_getter" do
    context "with a :_links property" do
      let(:properties) { { '_links' => 'foo' } }

      it "should create a :links property" do
        wrapper.links.should == 'foo'
      end
    end
    context "with a :_embedded property" do
      let(:properties) { { '_embedded' => 'foo' } }

      it "should create a :resources property" do
        wrapper.resources.should == 'foo'
      end
    end
  end
end