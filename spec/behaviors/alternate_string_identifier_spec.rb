require 'spec_helper'

describe Frenetic::Behaviors::AlternateStringIdentifier do
  let(:my_temp_resource) do
    Class.new(Frenetic::Resource)
  end

  before do
    stub_const 'MyTempResource', my_temp_resource
    MyTempResource.send(:extend, described_class)
  end

  describe '.finder_params' do
    let(:id) { }
    let(:alternate_key) { }

    subject { MyTempResource.finder_params(id, alternate_key) }

    context 'with a Fixnum identifier' do
      let(:id) { 1 }

      it 'uses :id for the finder key' do
        expect(subject).to include id:id
      end
    end

    context 'with a String identifier representing a Fixnum' do
      let(:id) { '100' }

      it 'uses :id for the finder key' do
        expect(subject).to include id:id
      end
    end

    context 'with a String identifier' do
      let(:id) { 'foo' }
      let(:alternate_key) { 'alt' }

      it 'uses :id for the finder key' do
        expect(subject).to include 'alt' => id
      end
    end
  end
end
