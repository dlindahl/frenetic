require 'spec_helper'

describe BrieflyMemoizable do
  let(:my_class) { Class.new }

  before do
    stub_const 'MyClass', my_class

    MyClass.send :include, described_class
    MyClass.class_eval do
      def fetch
        @fetch_age = Time.now + 3600

        external_call
      end
      briefly_memoize :fetch

      def external_call
        true
      end
    end
  end

  let(:instance) { MyClass.new }

  describe '.briefly_memoize' do
    context 'for an expensive method' do
      before do
        Timecop.freeze

        instance.fetch
      end

      context 'which is called again outside the memoize window' do
        before do
          Timecop.travel Time.now + 5400
        end

        it 'should be called' do
          instance.should_receive(:external_call).once.and_call_original

          instance.fetch
        end
      end

      context 'which is called again within the memoize window' do
        before do
          Timecop.travel Time.now + 1800
        end

        it 'should not be called' do
          instance.should_receive(:external_call).never.and_call_original

          instance.fetch
        end
      end
    end
  end
end