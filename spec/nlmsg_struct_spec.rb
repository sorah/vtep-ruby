require 'vtep/nlmsg_struct'
RSpec.describe Vtep::NlmsgStruct do
  let(:klass_simple) do
    Class.new(Vtep::NlmsgStruct) do
      member :foo, 'S'
      member :bar, 'S'
    end
  end

  let(:klass_nested) do
    klass_simple = klass_simple()
    Class.new(Vtep::NlmsgStruct) do
      member :foo, 'S'
      member :simple, klass_simple
      member :bar, 'S'
    end
  end

  let(:klass_nla) do
    Class.new(Vtep::NlmsgStruct) do
      member :foo, 'S'
      nla(
        NDA_VLAN: 'S',
      )
    end
  end

  describe ".parse" do
    context "with simple members" do
      subject { klass_simple.parse([1,2].pack('SS')) }
      it "parses correctly" do
        expect(subject.foo).to eq 1
        expect(subject.bar).to eq 2
      end
    end

    context "with nested members" do
      subject { klass_nested.parse([1,2,3,4].pack('SSSS')) }
      it "parses correctly" do
        expect(subject.foo).to eq 1
        expect(subject.simple.foo).to eq 2
        expect(subject.simple.bar).to eq 3
        expect(subject.bar).to eq 4
      end
    end

    context "with NLA" do
      subject { klass_nla.parse([1,4,0,1].pack('SSSS')) }

      it "parses collectly" do
        expect(subject.foo).to eq 1
        p subject.nla_list
      end
    end
  end

  describe ".pack" do
    context "with simple members" do
      let(:string) { [1,2].pack('SS') }
      subject { klass_simple.parse(string).pack }
      it { is_expected.to eq(string) }
    end

    context "with nested members" do
      let(:string) { [1,2,3,4].pack('SSSS') }
      subject { klass_nested.parse(string).pack }
      it { is_expected.to eq(string) }
    end
  end
end
