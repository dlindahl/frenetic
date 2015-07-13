require 'spec_helper'

describe Frenetic::StructureRegistry::Retriever do
  let(:rebuilder_class) { Frenetic::StructureRegistry::Rebuilder }
  let(:signatures) { {} }
  let(:resource) { Class.new }
  let(:attributes) do
    {
      'id' => 123
    }
  end
  let(:key) { 'MockKey' }

  subject(:instance) do
    described_class.new(signatures, resource, attributes, key, rebuilder_class: rebuilder_class)
  end

  describe '#initialize' do
    context 'with a blank :key argument' do
      let(:key) { '  ' }

      it 'raises an error' do
        expect{subject}.to raise_error(ArgumentError, /non-blank/)
      end
    end
  end

  describe '#call' do
    let(:rebuilder) { double('Rebuilder') }
    let(:rebuilder_class) { double('RebuilderClass', new: rebuilder) }

    subject { super().call }

    context 'for an expired resource registration' do
      before do
        allow(instance).to receive(:expired?).and_return(true)
      end

      it 'invokes the Rebuilder' do
        allow(rebuilder).to receive(:call)
        subject
        expect(rebuilder).to have_received(:call)
      end
    end

    context 'for an un-expired resource registration' do
      before do
        allow(instance).to receive(:expired?).and_return(false)
      end

      it 'fetches the resource' do
        allow(instance).to receive(:fetch_structure).and_return(true)
        subject
        expect(instance).to have_received(:fetch_structure)
      end
    end
  end

  describe '#expired?' do
    let(:resource_signature) { 'mock_signature' }
    let(:signatures) do
      {
        key => resource_signature
      }
    end

    before do
      allow(instance).to receive(:struct_signature).and_return resource_signature
    end

    subject { super().expired? }

    context 'for an un-registered resource' do
      let(:signatures) { {} }

      it 'returns TRUE' do
        expect(subject).to eql true
      end
    end

    context 'for an expired resource' do
      let(:signatures) do
        {
          key => resource_signature + 'OLD'
        }
      end

      it 'returns TRUE' do
        expect(subject).to eql true
      end
    end

    context 'for an un-expired resource' do
      it 'returns FALSE' do
        expect(subject).to eql false
      end
    end
  end

  describe '#fetch_structure' do
    before { Struct.new(key) }

    after { Struct.send(:remove_const, key) }

    subject { super().fetch_structure }

    it 'returns the registered Struct class' do
      expect(subject).to eql Struct::MockKey
    end
  end

  describe '#struct_signature' do
    subject { super().struct_signature }

    it 'returns a unique signature for a given resource' do
      expect(subject).to match(/\A[a-z0-9]{40}\z/)
    end
  end
end
