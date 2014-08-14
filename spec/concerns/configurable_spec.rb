require 'spec_helper'

describe Frenetic::Configurable do
  let(:test_cfg) do
    { url:'http://example.org' }
  end

  subject(:instance) { Frenetic.new(test_cfg) }

  describe '#config' do
    subject { super().config }

    it 'is not empty' do
      expect(subject).to_not be_empty
    end
  end

  describe '#configure' do
    subject do
      cfg = nil
      super().configure {|c| cfg = c }
      cfg
    end

    it 'yields the configuration' do
      expect(subject).to be_a Hash
    end
  end

  describe '.configure' do
    subject { Frenetic.configure{|c|} }

    it 'does not exist' do
      expect{subject}.to raise_error NoMethodError
    end
  end

  describe '#initialize' do
    let(:callback) do
      Proc.new {|b| }
    end

    subject do
      Frenetic.new(&callback).instance_variable_get('@builder_config')
    end

    it 'retain block arguments' do
      expect(subject).to eq callback
    end
  end
end