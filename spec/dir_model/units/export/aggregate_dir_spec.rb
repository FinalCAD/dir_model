require 'spec_helper'

describe DirModel::Export::AggregateDir do
  let(:file_contents)          { File.new('spec/fixtures/image.png').read }
  let(:export_dir_model_class) { BasicExportDirModel }
  let(:instance)               { DirModel::Export::AggregateDir.new }
  let(:file_paths) do
    [
      'Sectors/sector_name/zone_name.png',
      'Sectors/sector_name/fu_zone_name.png',
    ]
  end

  describe "#generate" do
    subject do
      models.each do |model|
        instance.generate do |dir|
          dir.append_model(export_dir_model_class, model)
        end
      end
    end

    it 'should be generate files' do
      subject

      file_paths.each do |file_path|
        expect(
          File.exists?(
            File.join(instance.dir_path, file_path))
        ).to be_truthy
      end
    end
  end
end
