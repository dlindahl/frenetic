require 'spec_helper'

describe Frenetic::StructureMethodDefiner do
  let(:my_temp_resource) { Class.new }

  before do
    stub_const('MyTempResource', my_temp_resource)
    MyTempResource.send(:extend, described_class)
  end

  describe '.structure' do
    before do
      MyTempResource.structure do
        123
      end
    end

    subject { MyTempResource.instance_variable_get('@_structure_block') }

    it 'stores a reference to the block' do
      expect(subject).to_not be_nil
    end
  end
end
