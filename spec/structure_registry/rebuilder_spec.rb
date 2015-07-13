require 'spec_helper'

describe Frenetic::StructureRegistry::Rebuilder do
  let(:signatures) { {} }
  let(:resource) { Class.new }
  let(:attributes) do
    {
      'id' => 123
    }
  end
  let(:key) { 'MockKey' }
  let(:signature) { 'abc123def456' }

  subject(:instance) { described_class.new(signatures, resource, attributes, key, signature) }

  after do
    Struct.send(:remove_const, key) if Struct.constants.include?(key.to_sym)
  end

  describe '#call' do
    subject { super().call }

    it 'removes any existing registration' do
      allow(instance).to receive(:destroy!)
      subject
      expect(instance).to have_received(:destroy!)
    end

    it 'registers the Struct signature' do
      subject
      expect(instance.signatures[key]).to eql signature
    end

    it 'returns a Struct for the given resource' do
      expect(subject).to eql Struct::MockKey
    end
  end

  describe '#destroy!' do
    let!(:struct) { Struct.new(key) }

    subject { super().destroy! }

    it 'removes the registered signature' do
      subject
      expect(instance.signatures).to_not include(key)
    end

    it 'removes the registered Struct constant' do
      subject
      expect{Struct.const_get(key.to_sym)}.to raise_error(NameError, %r[uninitialized constant Struct::#{key}])
    end

    context 'for a non-existant struct' do
      before do
        allow(instance).to receive(:exists?).and_return(false)
      end

      it 'does nothing' do
        subject
        expect(Struct.const_get(key)).to_not be_nil
      end
    end
  end

  describe '#exists?' do
    subject { super().exists? }

    context 'for a registered resource' do
      let!(:struct) { Struct.new(key) }

      it 'returns TRUE' do
        expect(subject).to eql true
      end
    end

    context 'for an un-registered resource' do
      it 'returns FALSE' do
        expect(subject).to eql false
      end
    end
  end
end
