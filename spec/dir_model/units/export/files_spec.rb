require 'spec_helper'

describe DirModel::Export::Files do
  let(:source_model) { double }
  let(:klass)        { BasicExportDirModel }
  let(:instance)     { klass.new(source_model, {}) }

  it 'should have skip? method' do
    expect(instance).to be_respond_to(:skip?)
  end

  shared_examples 'call source_model file and file extension method' do |extension|
    it 'should have :image method' do
      expect(instance).to be_respond_to(:image)
      expect(instance.image.read).to eql('file content')
      expect(instance).to be_respond_to(:image_extension)
      expect(instance.image_extension).to eql(extension)
    end
  end

  describe '.define_file_method' do
    let(:klass)  { Class.new(BasicExportDirModel) { file :image } } # NOTE Understand why test fail without this line

    context 'regular file method' do
      let(:source_model) { OpenStruct.new({image: double(:file, read: 'file content')}) }
      it_behaves_like 'call source_model file and file extension method', nil
    end

    context 'carrierwave uploader file method' do
      let(:source_model) { OpenStruct.new({image: double(:file, file: double(extension: :png, read: 'file content'))}) }
      it_behaves_like 'call source_model file and file extension method', :png
    end
  end
end
