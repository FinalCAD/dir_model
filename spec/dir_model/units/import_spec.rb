require 'spec_helper'

describe DirModel::Import do
  let(:klass) do
    Class.new do
      include DirModel::Model
      include DirModel::Import
    end
  end
  let(:context)     {{  }}
  let(:source_path) { nil }
  let(:instance)    { klass.new(source_path, context) }

  describe '#match?' do
    let(:klass) { BasicImportDirModel }

    subject { instance.send :match? }

    context "when path doesn't match" do
      let(:source_path) { 'spec/fixtures/unzip_dir/sectors' }

      it 'should return false' do
        expect(subject).to be_falsey
        expect(instance.instance_variable_get(:@_match)).to be_falsey
      end
    end

    context 'when path match' do
      let(:source_path) { 'zones/sector_1/zone_1.png' }

      it 'should return true' do
        expect(subject).to be_truthy
        expect(instance.instance_variable_get(:@_match)).to be_truthy 
      end

      it 'should match information' do
        subject
        expect(instance.instance_variable_get(:@_match)[:sector_id]).to eql('1')
        expect(instance.instance_variable_get(:@_match)[:zone_id]).to   eql('1')
        expect(instance.instance_variable_get(:@_match)[:extension]).to eql('png')
      end

      it 'match should be accessible through methods' do
        expect(instance.sector_id).to eql('1')
        expect(instance.zone_id).to   eql('1')
        expect(instance.extension).to eql('png')
        expect { instance.unexisting_method }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#get_regexp" do
    subject { instance.send(:get_regexp) }

    context "when proc that implements #instance_exec" do
      before do
        klass.class_eval do
          file :blah, regex: -> { /some_#{custom}_stuff/ }
          def custom; "waka" end
        end
      end

      it "calls instance exec to generate the regex" do
        expect(subject.to_s).to eql "(?-mix:some_waka_stuff)"
      end
    end
  end
end
