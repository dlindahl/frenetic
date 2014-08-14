require 'spec_helper'

describe Frenetic::Structured do
  let(:my_temp_resource) do
    Class.new do
      def initialize( attrs = {} )
        @attrs = attrs
      end
    end
  end

  before do
    stub_const 'MyTempResource', my_temp_resource
    MyTempResource.send :include, described_class
  end

  after do
    RSpec::Mocks.proxy_for(instance).reset
    instance.destroy_structure!
  end

  subject(:instance) { MyTempResource.new( foo:'foo', bar:'bar' ) }

  describe '#struct_key' do
    subject { instance.struct_key }

    it 'should return a valid, unique Ruby constant name' do
      subject.should == 'MyTempResourceFreneticResourceStruct'
    end
  end

  describe '#signature' do
    subject { instance.signature }

    it 'should return a unique and predictable key' do
      subject.should == 'barfoo'
    end
  end

  describe '#structure' do
    subject { instance.structure }

    context 'with no previously defined signature' do
      before do
        instance.stub( :structure_expired? ).and_return true
      end

      it 'should rebuild the structure' do
        instance.should_receive :rebuild_structure!

        subject
      end
    end

    context 'with a fresh signature' do
      before do
        instance.structure

        instance.stub( :structure_expired? ).and_return false
      end

      it 'should not rebuild the structure' do
        instance.should_receive( :rebuild_structure! ).never

        subject
      end
    end

    context 'with an expired signature' do
      before do
        instance.structure

        instance.stub( :structure_expired? ).and_return true
      end

      it 'should rebuild the structure' do
        instance.should_receive :rebuild_structure!

        subject
      end
    end
  end

  describe '#fetch_structure' do
    before { instance.structure }

    subject { instance.fetch_structure }

    it "should return the resource's Struct class" do
      subject.should == Struct::MyTempResourceFreneticResourceStruct
    end
  end

  describe '#rebuild_structure!' do
    before{ instance.structure }

    subject { instance.rebuild_structure! }

    it 'should destroy the previous Struct' do
      instance.should_receive(:destroy_structure!).and_call_original

      subject
    end

    it "should add cache the resource's signature" do
      sigs = described_class.class_variable_get('@@signatures')

      sigs.should include
    end

    it "should build the resource's Struct" do
      subject

      instance.fetch_structure.members.should == [:foo, :bar]
    end
  end

  describe '#structure_expired?' do
    subject { instance.structure_expired? }

    before do
      instance.stub( :signature ).and_return new_sig
      described_class.class_variable_set '@@signatures', {
        'MyTempResourceFreneticResourceStruct' => old_sig
      }
    end

    context 'with a fresh signature' do
      let(:old_sig) { 'fresh' }
      let(:new_sig) { 'fresh' }

      it { should be_falsey }
    end

    context 'with no predefined signature' do
      let(:old_sig) { nil }
      let(:new_sig) { 'new' }

      it { should be_truthy }
    end

    context 'with an expired signature' do
      let(:old_sig) { 'old' }
      let(:new_sig) { 'new' }

      it { should be_truthy }
    end
  end

  describe '#structure_defined?' do
    subject { instance.structure_defined? }

    let(:consts) { Struct.constants || [] }

    before do
      Struct.stub(:constants).and_return consts
    end

    after { RSpec::Mocks.proxy_for(Struct).reset }

    it 'should check if the structure is defined' do
      instance.stub(:struct_key).and_return 'Foo'

      consts.should_receive( :include? ).with :Foo

      subject
    end
  end

  describe '#destroy_structure!' do
    before { instance.structure }

    subject { instance.destroy_structure! }

    context 'with an undefined structure' do
      before { instance.destroy_structure! }

      it "should not attempt to remove the structure's constant" do
        Struct.should_receive( :remove_const ).never

        subject
      end

      it 'should not remove the signature from the cache' do
        described_class.class_variable_get('@@signatures').should_receive( :delete ).never

        subject
      end
    end

    context 'with an predefined structure' do
      it 'should remove the constant' do
        Struct.constants.should include instance.struct_key.to_sym

        subject

        Struct.constants.should_not include instance.struct_key.to_sym
      end

      it 'should remove the signature from the cache' do
        signature = { 'MyTempResourceFreneticResourceStruct' => 'barfoo' }

        described_class.class_variable_get('@@signatures').should include signature

        subject

        described_class.class_variable_get('@@signatures').should_not include signature
      end
    end
  end

end