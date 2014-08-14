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
        allow(instance).to receive(:external_call).and_call_original
      end

      context 'which is called again outside the memoize window' do
        before { Timecop.travel Time.now + 5400 }

        it 'is called' do
          instance.fetch
          expect(instance).to have_received(:external_call).once
        end
      end

      context 'which is called again within the memoize window' do
        before { Timecop.travel Time.now + 1800 }

        it 'is not called' do
          instance.fetch
          expect(instance).to_not have_received(:external_call)
        end

        context 'after it has been reloaded' do
          before { instance.reload_fetch! }

          it 'is called' do
            instance.fetch
            expect(instance).to have_received(:external_call).once
          end
        end
      end
    end
  end
end