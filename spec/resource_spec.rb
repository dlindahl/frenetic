require 'spec_helper'

describe Frenetic::Resource do
  let(:test_cfg) { { url:'http://example.com/api' } }

  let(:my_temp_resource) do
    cfg = test_cfg

    Class.new(described_class) do
      api_client { Frenetic.new(cfg) }
    end
  end

  before do
    stub_const 'MyNamespace::MyTempResource', my_temp_resource
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
      stub_const 'MyNamespace::MyTempResource', my_temp_resource
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

    subject { MyNamespace::MyTempResource.new(name:'me').attributes }

    it { should == { 'name' => 'me' } }
  end

end