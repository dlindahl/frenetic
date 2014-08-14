require 'spec_helper'

describe Frenetic::Structured do
  let(:my_temp_resource) do
    Class.new do
      def initialize( attrs = {} )
        @attrs = attrs
      end
    end
  end

  let(:signatures) do
    described_class.class_variable_get('@@signatures')
  end

  let(:signature) do
    { 'MyTempResourceFreneticResourceStruct' => 'barfoo' }
  end

  before do
    stub_const 'MyTempResource', my_temp_resource
    MyTempResource.send :include, described_class
  end

  after { instance.destroy_structure! }

  subject(:instance) { MyTempResource.new( foo:'foo', bar:'bar' ) }

  describe '#struct_key' do
    subject { super().struct_key }

    it 'returns a valid, unique Ruby constant name' do
      expect(subject).to eq 'MyTempResourceFreneticResourceStruct'
    end
  end

  describe '#signature' do
    subject { super().signature }

    it 'returns a unique and predictable key' do
      expect(subject).to eq 'barfoo'
    end
  end

  describe '#structure' do
    subject { super().structure }

    context 'with no previously defined signature' do
      before do
        allow(instance).to receive(:structure_expired?).and_return(true)
      end

      it 'rebuilds the structure' do
        allow(instance).to receive(:rebuild_structure!).and_call_original
        subject
        expect(instance).to have_received(:rebuild_structure!)
      end
    end

    context 'with a fresh signature' do
      before do
        instance.structure
        allow(instance).to receive(:structure_expired?).and_return(false)
      end

      it 'does not rebuild the structure' do
        allow(instance).to receive(:rebuild_structure!)
        subject
        expect(instance).to_not have_received(:rebuild_structure!)
      end
    end

    context 'with an expired signature' do
      before do
        instance.structure
        allow(instance).to receive(:structure_expired?).and_return(true)
      end

      it 'rebuilds the structure' do
        allow(instance).to receive(:rebuild_structure!)
        subject
        expect(instance).to have_received(:rebuild_structure!)
      end
    end
  end

  describe '#fetch_structure' do
    before { instance.structure }

    subject { super().fetch_structure }

    it 'returns the Struct class of the resource' do
      expect(subject).to eq Struct::MyTempResourceFreneticResourceStruct
    end
  end

  describe '#rebuild_structure!' do
    before{ instance.structure }

    subject { super().rebuild_structure! }

    it 'destroys the previous Struct' do
      allow(instance).to receive(:destroy_structure!).and_call_original
      subject
      expect(instance).to have_received(:destroy_structure!)
    end

    it 'caches the signature of the resource' do
      subject
      expect(signatures).to include signature
    end

    it 'builds the Struct resource' do
      subject
      expect(instance.fetch_structure.members).to eq [:foo, :bar]
    end
  end

  describe '#structure_expired?' do
    subject { super().structure_expired? }

    before do
      allow(instance).to receive(:signature).and_return(new_sig)
      described_class.class_variable_set '@@signatures', {
        'MyTempResourceFreneticResourceStruct' => old_sig
      }
    end

    context 'with a fresh signature' do
      let(:old_sig) { 'fresh' }
      let(:new_sig) { 'fresh' }

      it 'return FALSE' do
        expect(subject).to eq false
      end
    end

    context 'with no predefined signature' do
      let(:old_sig) { nil }
      let(:new_sig) { 'new' }

      it 'returns TRUE' do
        expect(subject).to eq true
      end
    end

    context 'with an expired signature' do
      let(:old_sig) { 'old' }
      let(:new_sig) { 'new' }

      it 'returns TRUE' do
        expect(subject).to eq true
      end
    end
  end

  describe '#structure_defined?' do
    let(:consts) { Struct.constants || [] }

    before do
      allow(Struct).to receive(:constants).and_return(consts)
    end

    subject { super().structure_defined? }

    it 'checks if the structure is defined' do
      allow(instance).to receive(:struct_key).and_return('Foo')
      allow(consts).to receive(:include?)
      subject
      expect(consts).to have_received(:include?).with(:Foo)
    end
  end

  describe '#destroy_structure!' do
    before { instance.structure }

    subject { super().destroy_structure! }

    context 'with an undefined structure' do
      before { instance.destroy_structure! }

      it 'does not attempt to remove the constant from the Struct' do
        allow(Struct).to receive(:remove_const)
        subject
        expect(Struct).to_not have_received(:remove_const)
      end

      it 'does not remove the signature from the cache' do
        allow(signatures).to receive(:delete)
        subject
        expect(signatures).to_not receive(:delete)
      end
    end

    context 'with an predefined structure' do
      it 'removes the constant' do
        expect(Struct.constants).to include instance.struct_key.to_sym
        subject
        expect(Struct.constants).to_not include instance.struct_key.to_sym
      end

      it 'removes the signature from the cache' do
        expect(signatures).to include signature
        subject
        expect(signatures).to_not include signature
      end
    end
  end
end