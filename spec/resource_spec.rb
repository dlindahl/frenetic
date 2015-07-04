require 'spec_helper'

describe Frenetic::Resource do
  let(:test_cfg) { { url:'http://example.com/api' } }
  let(:abstract_resource) do
    cfg = test_cfg

    Class.new(described_class) do
      api_client { Frenetic.new(cfg) }
    end
  end
  let(:mock_abstract_resource) do
    Class.new(MyNamespace::MyTempResource) do
      include Frenetic::ResourceMockery
    end
  end

  before do
    stub_const 'MyNamespace::MyTempResource', abstract_resource
    stub_const 'MyNamespace::MockMyTempResource', mock_abstract_resource
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
        before { configure_with_block! }

        subject { MyNamespace::MyTempResource.instance_variable_get '@api_client' }

        it 'saves a reference to the argument' do
          expect(subject).to be_a Proc
        end
      end

      context 'a Frenetic instance' do
        before { configure_with_instance! }

        subject { MyNamespace::MyTempResource.instance_variable_get '@api_client' }

        it 'saves a reference to the argument' do
          expect(subject).to be_an_instance_of Frenetic
        end
      end

      context 'no argument' do
        subject { MyNamespace::MyTempResource.api_client }

        context 'and a previously stored @api_client' do
          context 'Proc' do
            before { configure_with_block! }

            let(:api_client) do
              MyNamespace::MyTempResource.instance_variable_get('@api_client')
            end

            it 'calls the Proc' do
              allow(api_client).to receive(:call)
              subject
              expect(api_client).to have_received(:call)
            end
          end

          context 'Frenetic instance' do
            before { configure_with_instance! }

            it 'returns the instance' do
              expect(subject).to be_an_instance_of Frenetic
            end
          end
        end
      end
    end
  end

  describe '.extract_embedded_resources' do
    let(:resource) do
      {
        '_embedded' => {
          'my_temp_resource' => {
            'id' => 99
          }
        }
      }
    end

    before { @stubs.api_description }

    subject do
      MyNamespace::MyTempResource.extract_embedded_resources(resource)
    end

    it 'extracts all embedded resources' do
      expect(subject).to include 'my_temp_resource' => kind_of(MyNamespace::MyTempResource)
    end
  end

  describe '.find_resource_class' do
    let(:params) do
      {
        id: 54,
        _links: {
          known_resource: {
            href: '/known_resource'
          }
        }
      }
    end

    before do
      @stubs.api_description
      stub_const('MyNamespace::KnownResource', abstract_resource)
    end

    subject do
      MyNamespace::MyTempResource.find_resource_class(resource_name)
    end

    context 'with a known resource' do
      let(:resource_name) { 'known_resource' }

      it 'returns the resource class' do
        expect(subject).to eql MyNamespace::KnownResource
      end
    end

    context 'with an unknown resource' do
      let(:resource_name) { 'unknown_resource' }

      it 'returns an anonymous class' do
        expect(subject).to eql OpenStruct
      end
    end
  end

  describe '.namespace' do
    before do
      stub_const 'MyNamespace::MyTempResource', abstract_resource
    end

    subject { MyNamespace::MyTempResource.namespace }

    let(:namespace) do
      MyNamespace::MyTempResource.instance_variable_get('@namespace')
    end

    context 'with an argument' do
      before do
        MyNamespace::MyTempResource.class_eval do
          namespace :test_spec
        end
      end

      it 'returns that value' do
        expect(subject).to eq 'test_spec'
      end

      it 'internally saves the value' do
        subject
        expect(namespace).to eq 'test_spec'
      end
    end

    context 'with no argument' do
      it 'infers the value' do
        expect(subject).to eq 'my_temp_resource'
      end

      it 'caches the inferrence' do
        subject
        expect(namespace).to eq 'my_temp_resource'
      end
    end
  end

  describe '.properties' do
    before { @stubs.api_description }

    subject { MyNamespace::MyTempResource.properties }

    context 'for a known resource' do
      it 'returns a list of properties defined by the API' do
        expect(subject).to_not be_empty
      end
    end

    context 'for an unknown resource' do
      before do
        allow(MyNamespace::MyTempResource)
          .to receive(:namespace)
          .and_return(Time.now.to_i.to_s)
      end

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::MissingSchemaDefinition
      end
    end

    context 'in test mode' do
      let(:mock_abstract_resource) do
        Class.new(MyNamespace::MyTempResource) do
          include Frenetic::ResourceMockery

          def self.default_attributes
            { foo:123 }
          end
        end
      end

      before do
        stub_const 'MyNamespace::MockMyTempResource', mock_abstract_resource
        allow(MyNamespace::MyTempResource)
          .to receive(:test_mode?)
          .and_return(true)
      end

      it 'returns the default attributes of the mock' do
        expect(subject).to eq(foo:123)
      end
    end
  end

  describe '.as_mock' do
    subject { MyNamespace::MyTempResource.as_mock id:99 }

    before do
      stub_const 'MyNamespace::MyMockResource', Class.new(MyNamespace::MyTempResource)
      MyNamespace::MyMockResource.send :include, Frenetic::ResourceMockery
    end

    it 'initializes the mock with the provided values' do
      expect(subject.id).to eq 99
    end
  end

  describe '.mock_class' do
    subject { MyNamespace::MyTempResource.mock_class }

    context 'without a defined Mock-class' do
      let(:mock_abstract_resource) { Class.new }

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::UndefinedResourceMock
      end
    end

    context 'with a defined Mock-class' do
      before do
        stub_const 'MyNamespace::MyMockResource', Class.new(MyNamespace::MyTempResource)
        MyNamespace::MyMockResource.send :include, Frenetic::ResourceMockery
      end

      it 'returns a mock instance of the resource' do
        expect(subject).to eq MyNamespace::MyMockResource
      end
    end
  end

  describe '#initialize' do
    before { @stubs.api_description }

    subject { MyNamespace::MyTempResource.new args }

    context 'with no arguments' do
      let(:args) {}

      it 'has default attributes' do
        expect(subject.name).to be_nil
      end
    end

    context 'with known attributes' do
      let(:args) { { name:'foo' } }

      it 'sets the appropriate values' do
        expect(subject.name).to eq 'foo'
      end

      context 'and an embedded resource' do
        let(:args) do
          super().merge(
            '_embedded' => {
              'embedded_resource' => {
                'id' => 99,
                'genus' => 'canine'
              }
            }
          )
        end

        context 'that is of a known type' do
          before do
            stub_const 'MyNamespace::EmbeddedResource', abstract_resource
          end

          it 'instantiates the embedded resource' do
            expect(subject.embedded_resource).to be_an_instance_of MyNamespace::EmbeddedResource
          end
        end

        context 'that is of an unknown type' do
          it 'instantiates a shim of the embedded resource' do
            expect(subject.embedded_resource).to be_an_instance_of OpenStruct
          end

          context 'and test mode is enabled' do
            before do
              allow(abstract_resource).to receive(:test_mode?).and_return(true)
            end

            it 'instantiates a shim of the embedded resource' do
              expect(subject.embedded_resource).to be_an_instance_of OpenStruct
            end
          end
        end
      end
    end

    context 'with unknown attributes' do
      let(:args) { { gender:'male' } }

      it 'does not create accessors' do
        expect{subject.gender}.to raise_error(NoMethodError)
      end

      it 'is accessible in @params' do
        params = subject.instance_variable_get('@params')
        expect(params).to include 'gender' => 'male'
      end
    end

    context 'for a schemaless resource' do
      let(:args) {}

      before do
        allow(MyNamespace::MyTempResource)
          .to receive(:namespace)
          .and_return(Time.now.to_i.to_s)
      end

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::HypermediaError
      end
    end
  end

  describe '#attributes' do
    before { @stubs.api_description }

    subject { MyNamespace::MyTempResource.new(id:54, name:'me').attributes }

    it 'returns attributes of the resource' do
      expect(subject).to eq('id' => 54, 'name' => 'me')
    end
  end
end
