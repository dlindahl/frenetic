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
    stub_const 'MyNamespace::MyResource', my_temp_resource
  end

  describe '.api_client' do
    context 'calling with' do
      def configure_with_block!
        cfg_copy = test_cfg

        MyNamespace::MyResource.class_eval do
          api_client { Frenetic.new(cfg_copy) }
        end
      end

      def configure_with_instance!
        cfg_copy = test_cfg

        MyNamespace::MyResource.class_eval do
          api_client Frenetic.new(cfg_copy)
        end
      end

      context 'a block argument' do
        before do
          configure_with_block!
        end

        subject { MyNamespace::MyResource.instance_variable_get '@api_client' }

        it 'should save a reference to the argument' do
          subject.should be_a Proc
        end
      end

      context 'a Frenetic instance' do
        before do
          configure_with_instance!
        end

        subject { MyNamespace::MyResource.instance_variable_get '@api_client' }

        it 'should save a reference to the argument' do
          subject.should be_an_instance_of Frenetic
        end
      end

      context 'no argument' do
        subject { MyNamespace::MyResource.api_client }

        context 'and a previously stored @api_client' do
          context 'Proc' do
            before do
              configure_with_block!
            end

            it 'should call the Proc' do
              MyNamespace::MyResource.instance_variable_get('@api_client')
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
      stub_const 'MyNamespace::MyResource', my_temp_resource
    end

    subject { MyNamespace::MyResource.namespace }

    context 'with an argument' do
      before do
        MyNamespace::MyResource.class_eval do
          namespace :test_spec
        end
      end

      it 'should return that value' do
        subject.should == 'test_spec'
      end

      it 'should internally save the value' do
        subject

        ns = MyNamespace::MyResource.instance_variable_get '@namespace'

        ns.should == 'test_spec'
      end
    end

    context 'with no argument' do
      it 'should infer the value' do
        subject.should == 'my_resource'
      end

      it 'should cache the inferrence' do
        subject

        ns = MyNamespace::MyResource.instance_variable_get '@namespace'

        ns.should == 'my_resource'
      end
    end
  end

end