require 'spec_helper'

describe Frenetic::HypermediaLink do
  let(:basic_link) do
    { href:'/api/my_link' }
  end

  let(:templated_link) do
    { href:'/api/my_link/{id}-{title}', templated:true }
  end

  let(:relation_link) do
    { href:'/api/foo', rel:'foo' }
  end

  subject { described_class.new(link) }

  describe '#href' do
    subject { super().href data }

    context 'with a non-templated link' do
      let(:link) { basic_link }
      let(:data) {}

      it 'correctly transforms the data' do
        expect(subject).to eq '/api/my_link'
      end
    end

    context 'with a templated link' do
      let(:link) { templated_link }

      context 'and complate template data' do
        let(:data) { { id:1, title:'title' } }

        it 'correctly transforms the data' do
          expect(subject).to eq '/api/my_link/1-title'
        end
      end

      context 'and incomplete template data' do
        let(:data) { { id:1 } }

        it 'raises an error' do
          expect{subject}.to raise_error Frenetic::HypermediaError
        end
      end

      context 'and non-Hash template data' do
        let(:templated_link) do
          { href:'/api/my_link/{id}', templated:true }
        end

        let(:data) { 1 }

        it 'infers the template data' do
          expect(subject).to eq '/api/my_link/1'
        end
      end
    end
  end

  describe '#templated?' do
    subject { super().templated? }

    context 'with a non-templated link' do
      let(:link) { basic_link }

      it 'returns FALSE' do
        expect(subject).to eq false
      end
    end

    context 'with a templated link' do
      let(:link) { templated_link }

      it 'returns TRUE' do
        expect(subject).to eq true
      end
    end
  end

  describe '#expandable?' do
    subject { super().expandable? data }

    let(:link) { templated_link }

    context 'when the data can fully fulfill the template requirements' do
      let(:data) { { id:1, title:'title' } }

      it 'returns TRUE' do
        expect(subject).to eq true
      end
    end

    context 'when the data cannot fully fulfill the template requirements' do
      let(:data) { { id:1 } }

      it 'returns FALSE' do
        expect(subject).to eq false
      end
    end

    context 'when the data provides more than the template requires' do
      let(:data) { { id:1, title:'title', garbage:true } }

      it 'returns TRUE' do
        expect(subject).to eq true
      end
    end

    context 'with a non-template URL' do
      let(:link) { basic_link }

      let(:data) { { id:1 } }

      it 'returns FALSE' do
        expect(subject).to eq false
      end
    end
  end

  describe '#template' do
    subject { super().template }

    let(:link) { templated_link }

    it 'returns an Addressable Template' do
      expect(subject).to be_an_instance_of Addressable::Template
    end
  end

  describe '#as_json' do
    subject { super().as_json }

    let(:link) { templated_link }

    it 'returns a Hash representation of the link' do
      expect(subject).to include 'href' => '/api/my_link/{id}-{title}'
      expect(subject).to include 'templated' => true
    end
  end

  describe '#rel' do
    subject { super().rel }

    let(:link) { relation_link }

    it 'returns the relation name' do
      expect(subject).to eq 'foo'
    end
  end
end
