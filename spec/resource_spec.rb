require 'spec_helper'

describe Frenetic::Resource do
  let(:test_cfg) { { url:'http://example.com/api' } }


  describe '.api_client' do
    context 'calling with' do
      let(:my_class) { Class.new(described_class) }

      before do
        stub_const 'MyClass', my_class
      end

      def configure_with_block!
        cfg_copy = test_cfg

        MyClass.class_eval do
          api_client { Frenetic.new(cfg_copy) }
        end
      end

      def configure_with_instance!
        cfg_copy = test_cfg

        MyClass.class_eval do
          api_client Frenetic.new(cfg_copy)
        end
      end

      context 'a block argument' do
        before do
          configure_with_block!
        end

        subject { MyClass.instance_variable_get '@api_client' }

        it 'should save a reference to the argument' do
          subject.should be_a Proc
        end
      end

      context 'a Frenetic instance' do
        before do
          configure_with_instance!
        end

        subject { MyClass.instance_variable_get '@api_client' }

        it 'should save a reference to the argument' do
          subject.should be_an_instance_of Frenetic
        end
      end

      context 'no argument' do
        subject { MyClass.api_client }

        context 'and a previously stored @api_client' do
          context 'Proc' do
            before do
              configure_with_block!
            end

            it 'should call the Proc' do
              MyClass.instance_variable_get('@api_client')
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

end