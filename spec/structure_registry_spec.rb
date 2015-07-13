require 'spec_helper'

describe Frenetic::StructureRegistry do
  let(:retriever_class) { described_class::Retriever }

  subject(:instance) do
    Frenetic::StructureRegistry.new(retriever_class:retriever_class)
  end

  describe '#construct' do
    let(:resource) { Class.new }
    let(:attributes) do
      {
        'id' => 123
      }
    end
    let(:key) { 'MockKey' }

    subject { super().construct(resource, attributes, key) }

    it 'returns an instantiated Structure class' do
      expect(subject).to be_a Struct::MockKey
    end

    it 'assigns the specified attributes to the Struct instance' do
      expect(subject.id).to eq 123
    end

    it 'registers the Struct' do
      subject
      expect(instance.signatures).to_not be_empty
    end
  end

  describe '#fetch' do
    let(:mock_retriever) { double('MockRetriever') }
    let(:retriever_class) { double('MockRetrieverClass', new: mock_retriever) }
    let(:resource) { Class.new }
    let(:attributes) do
      {
        'id' => 123
      }
    end
    let(:key) { 'MockKey' }

    subject { super().fetch(resource, attributes, key) }

    it 'invokes Frenetic::StructureRegistry::Retriever#call' do
      allow(mock_retriever).to receive(:call)
      subject
      expect(mock_retriever).to have_received(:call)
    end
  end
end
