# 'spec/fixtures/unzip_dir/zones/sector_1+2/zone_1+2.dae.json'
class ZoneBimMetaImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :bim_meta, regex: ->(foreign_value) { /Zones\/#{foreign_value}\.(?<extension>dae\.json)/i }
end

# 'spec/fixtures/unzip_dir/zones/sector_1+2/zone_1+2.dae' Exclude .dae.json
class ZoneBimModelImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :bim_model, regex: ->(foreign_value) { /Zones\/#{foreign_value}\.(?<extension>dae)(?!\.\w\w\w)/i }
end

# 'spec/fixtures/unzip_dir/zones/sector_1+2/zone_1+2.json' Exclude .dae.json
class ZoneMetadataImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :metadata, regex: ->(foreign_value) { /Zones\/#{foreign_value}(?<!\.\w\w\w)\.(?<extension>json)/i }
end

class ZoneImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :image, regex: ->(foreign_value) { /Zones\/(?<sector_name>#{foreign_value})\/Zone_(?<zone_id>.*)\.(?<extension>png|jpg)/i }
  has_one :metadata,  ZoneMetadataImportDirModel, foreign_key: :sector_zone_name
  has_one :bim_model, ZoneBimModelImportDirModel, foreign_key: :sector_zone_name
  has_one :bim_meta,  ZoneBimMetaImportDirModel,  foreign_key: :sector_zone_name
  def sector_zone_name
    "#{Regexp.quote(sector_name)}\\/zone_#{Regexp.quote(zone_id)}"
  end
end

class SectorMetadataImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :metadata, regex: ->(foreign_value) { /Sectors\/#{foreign_value}\.(?<extension>json)/i }
end

class SectorImportDirModel
  include DirModel::Model
  include DirModel::Import

  file :image, regex: -> { /Sectors\/Sector_(?<sector_id>.*)\.(?<extension>png|jpg)/i }

  has_one :metadata, SectorMetadataImportDirModel, foreign_key: :sector_name
  has_many :children, ZoneImportDirModel, foreign_key: :sector_name

  def sector_name
    "sector_#{Regexp.quote(sector_id)}"
  end
end
