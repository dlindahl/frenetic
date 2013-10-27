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

  subject { described_class.new( link ) }

  describe '#href' do
    subject { super().href data }

    context 'with a non-templated link' do
      let(:link) { basic_link }

      let(:data) {}

      it 'should correctly transform the data' do
        expect(subject).to eq '/api/my_link'
      end
    end

    context 'with a templated link' do
      let(:link) { templated_link }

      context 'and complate template data' do
        let(:data) { { id:1, title:'title' } }

        it 'should correctly transform the data' do
          expect(subject).to eq '/api/my_link/1-title'
        end
      end

      context 'and incomplete template data' do
        let(:data) { { id:1 } }

        it 'should raise an error' do
          expect{subject}.to raise_error Frenetic::HypermediaError
        end
      end

      context 'and non-Hash template data' do
        let(:templated_link) do
          { href:'/api/my_link/{id}', templated:true }
        end

        let(:data) { 1 }

        it 'should infer the template data' do
          expect(subject).to eq '/api/my_link/1'
        end
      end
    end
  end

  describe '#templated?' do
    subject { super().templated? }

    context 'with a non-templated link' do
      let(:link) { basic_link }

      it { should be_false }
    end

    context 'with a templated link' do
      let(:link) { templated_link }

      it { should be_true }
    end
  end

  describe '#expandable?' do
    subject { super().expandable? data }

    let(:link) { templated_link }

    context 'when the data can fully fulfill the template requirements' do
      let(:data) { { id:1, title:'title' } }

      it { should be_true }
    end

    context 'when the data cannot fully fulfill the template requirements' do
      let(:data) { { id:1 } }

      it { should be_false }
    end

    context 'when the data provides more than the template requires' do
      let(:data) { { id:1, title:'title', garbage:true } }

      it { should be_true }
    end

    context 'with a non-template URL' do
      let(:link) { basic_link }

      let(:data) { { id:1 } }

      it { should be_false }
    end
  end

  describe '#template' do
    subject { super().template }

    let(:link) { templated_link }

    it { should be_an_instance_of Addressable::Template }
  end

  describe '#as_json' do
    subject { super().as_json }

    let(:link) { templated_link }

    it 'should return a Hash representation of the link' do
      subject.should include 'href'      => '/api/my_link/{id}-{title}'
      subject.should include 'templated' => true
    end
  end

  describe '#rel' do
    subject { super().rel }

    let(:link) { relation_link }

    it { should eq 'foo' }
  end

end