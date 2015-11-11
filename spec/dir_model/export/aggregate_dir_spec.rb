require 'spec_helper'

describe DirModel::Export::AggregateDir do
  let(:file_contents)    { File.new('spec/fixtures/image.png').read }
  let(:source_model)     { ModelImage.new }
  let(:instance)         { DirModel::Export::AggregateDir.new(ImageExportDir) }
  let(:file_path)        { 'Sectors/sector_name/zone_name.png' }

  describe "#generate" do
    subject { instance.generate { |dir| dir << source_model } }

    it 'should be generate files' do
      subject
      expect(File.exists?(File.join(instance.dir_path, file_path))).to be_truthy
    end
  end
end
