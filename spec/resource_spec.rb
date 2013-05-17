require 'spec_helper'

describe Frenetic::Resource do
  let(:test_cfg) { { url:'http://example.com/api' } }

  def abstract_resource
    cfg = test_cfg

    Class.new(described_class) do
      api_client { Frenetic.new(cfg) }
    end
  end

  before do
    stub_const 'MyNamespace::MyTempResource', abstract_resource
  end

  describe '.api_client' do
    context 'calling with' do
      def configure_with_block!
        cfg_copy = test_cfg

        MyNamespace::MyTempResource.class_eval do
          api_client { Frenetic.new(cfg_copy) }
        end
      end

      def configure_with_instance!
        cfg_copy = test_cfg

        MyNamespace::MyTempResource.class_eval do
          api_client Frenetic.new(cfg_copy)
        end
      end

      context 'a block argument' do
        before do
          configure_with_block!
        end

        subject { MyNamespace::MyTempResource.instance_variable_get '@api_client' }

        it 'should save a reference to the argument' do
          subject.should be_a Proc
        end
      end

      context 'a Frenetic instance' do
        before do
          configure_with_instance!
        end

        subject { MyNamespace::MyTempResource.instance_variable_get '@api_client' }

        it 'should save a reference to the argument' do
          subject.should be_an_instance_of Frenetic
        end
      end

      context 'no argument' do
        subject { MyNamespace::MyTempResource.api_client }

        context 'and a previously stored @api_client' do
          context 'Proc' do
            before do
              configure_with_block!
            end

            it 'should call the Proc' do
              MyNamespace::MyTempResource.instance_variable_get('@api_client')
                .should_receive 'call'

              subject
            end
          end

          context 'Frenetic instance' do
            before do
              configure_with_instance!
            end

            it 'should return the instance' do
              subject.should be_an_instance_of Frenetic
            end
          end
        end
      end
    end
  end

  describe '.namespace' do
    before do
      stub_const 'MyNamespace::MyTempResource', abstract_resource
    end

    subject { MyNamespace::MyTempResource.namespace }

    context 'with an argument' do
      before do
        MyNamespace::MyTempResource.class_eval do
          namespace :test_spec
        end
      end

      it 'should return that value' do
        subject.should == 'test_spec'
      end

      it 'should internally save the value' do
        subject

        ns = MyNamespace::MyTempResource.instance_variable_get '@namespace'

        ns.should == 'test_spec'
      end
    end

    context 'with no argument' do
      it 'should infer the value' do
        subject.should == 'my_temp_resource'
      end

      it 'should cache the inferrence' do
        subject

        ns = MyNamespace::MyTempResource.instance_variable_get '@namespace'

        ns.should == 'my_temp_resource'
      end
    end
  end

  describe '.properties' do
    before { @stubs.api_description }

    subject { MyNamespace::MyTempResource.properties }

    context 'for a known resource' do
      it 'should return a list of properties defined by the API' do
        subject.should_not be_empty
      end
    end

    context 'for an unknown resource' do
      before do
        MyNamespace::MyTempResource.stub(:namespace).and_return Time.now.to_i.to_s
      end

      it 'should raise an error' do
        expect{ subject }.to raise_error Frenetic::HypermediaError
      end
    end
  end

  describe '.as_mock' do
    subject { MyNamespace::MyTempResource.as_mock id:99 }

    before do
      stub_const 'MyNamespace::MyMockResource', Class.new(MyNamespace::MyTempResource)

      MyNamespace::MyMockResource.send :include, Frenetic::ResourceMockery
    end

    it 'should initialize the mock with the provided values' do
      expect(subject.id).to eq 99
    end
  end

  describe '.mock_class' do
    subject { MyNamespace::MyTempResource.mock_class }

    context 'without a defined Mock-class' do
      it 'should raise an error' do
        expect{subject}.to raise_error Frenetic::ClientError
      end
    end

    context 'with a defined Mock-class' do
      before do
        stub_const 'MyNamespace::MyMockResource', Class.new(MyNamespace::MyTempResource)

        MyNamespace::MyMockResource.send :include, Frenetic::ResourceMockery
      end

      it 'should return a mock instance of the resource' do
        expect(subject).to eq MyNamespace::MyMockResource
      end
    end
  end

  describe '#initialize' do
    before { @stubs.api_description }

    subject { MyNamespace::MyTempResource.new args }

    context 'with no arguments' do
      let(:args) {}

      it 'should have default attributes' do
        subject.name.should be_nil
      end
    end

    context 'with known attributes' do
      let(:args) { { name:'foo' } }

      it 'should set the appropriate values' do
        subject.name.should == 'foo'
      end

      context 'and an embedded resource' do
        let(:args) do
          super().merge({
            '_embedded' => {
              'abstract_resource' => {
                'id' => 99,
                'genus' => 'canine'
              }
            }
          })
        end

        context 'this is of a known type' do
          before do
            stub_const 'MyNamespace::AbstractResource', abstract_resource
          end

          it 'should instantiate the embedded resource' do
            expect(subject.abstract_resource).to be_an_instance_of MyNamespace::AbstractResource
          end
        end

        context 'this is of a known type' do
          it 'should instantiate a shim of the embedded resource' do
            expect(subject.abstract_resource).to be_an_instance_of OpenStruct
          end
        end
      end
    end

    context 'with unknown attributes' do
      let(:args) { { gender:'male' } }

      it 'should not create accessors' do
        expect{ subject.gender }.to raise_error NoMethodError
      end

      it 'should be accessible in @params' do
        params = subject.instance_variable_get( '@params' )

        params.should include 'gender' => 'male'
      end
    end

    context 'for a schemaless resource' do
      let(:args) {}

      before do
        MyNamespace::MyTempResource.stub(:namespace).and_return Time.now.to_i.to_s
      end

      it 'should raise an error' do
        expect{ subject }.to raise_error Frenetic::HypermediaError
      end
    end
  end

  describe '#attributes' do
    before { @stubs.api_description }

    subject { MyNamespace::MyTempResource.new(id:54, name:'me').attributes }

    it { should == { 'id' => 54, 'name' => 'me' } }
  end

end