require 'spec_helper'

describe Frenetic::Persistence do
  let(:test_cfg) { { url:'http://example.com/api' } }

  let(:my_temp_resource) do
    cfg = test_cfg

    Class.new(Frenetic::Resource) do
      api_client { Frenetic.new(cfg) }
    end
  end

  before do
    stub_const 'MyTempResource', my_temp_resource
    MyTempResource.send(:include, described_class)
  end

  subject(:instance) { MyTempResource.new }

  describe '#save' do
    before { @stubs.api_description }

    subject { super().save }

    context 'for a valid resource' do
      before { @stubs.valid_created_resource }

      it 'returns TRUE' do
        expect(subject).to eql true
      end

      it 'returns a valid instance' do
        subject
        expect(instance.valid?).to eql true
      end
    end

    context 'for an invalid resource' do
      before { @stubs.invalid_created_resource }

      it 'returns FALSE' do
        expect(subject).to eql false
      end

      it 'returns an invalid instance' do
        subject
        expect(instance.valid?).to eql false
      end

      it 'maps resource errors onto the instance' do
        subject
        expect(instance.errors).to include 'name' => ['cannot be blank', 'must be a name']
      end
    end

    context 'that triggers an exception' do
      let(:mock_api) { double('api_client') }

      before do
        @stubs.valid_created_resource
        allow(mock_api).to receive(:post).and_raise(StandardError)
        expect(instance).to receive(:api).and_return(mock_api)
      end

      it 're-raises the exception' do
        expect{subject}.to raise_error(StandardError)
      end
    end
  end

  describe '#save!' do
    before { @stubs.api_description }

    subject { super().save! }

    context 'for a valid resource' do
      before { @stubs.valid_created_resource }

      it 'returns TRUE' do
        expect(subject).to eql true
      end
    end

    context 'for an invalid resource' do
      before { @stubs.invalid_created_resource }

      it 'raises an error' do
        # rubocop:disable Metrics/LineLength
        expect{subject}.to raise_error(Frenetic::ClientError, 'Validation failed: Name cannot be blank, Name must be a name, Cannot be valid')
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
