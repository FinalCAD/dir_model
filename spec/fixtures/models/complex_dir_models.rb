class ZoneBimModelImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :metadata, regex: ->(foreign_value) { "Zones\/#{foreign_value}\.(?<extension>dae)" }
end

class ZoneMetadataImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :metadata, regex: ->(foreign_value) { "Zones\/#{foreign_value}\.(?<extension>json)" }
end

class ZoneImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :image, regex: ->(foreign_value) { "Zones\/(?<sector_name>#{foreign_value})\/Zone_(?<zone_id>.*)\.(?<extension>png|jpg)" }
  has_one :metadata, ZoneMetadataImportDirModel, foreign_key: :sector_zone_name
  has_one :bim_model, ZoneBimModelImportDirModel, foreign_key: :sector_zone_name
  def sector_zone_name
    "#{sector_name}\/zone_#{zone_id}"
  end
end

class SectorMetadataImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :metadata, regex: ->(foreign_value) { "Sectors\/#{foreign_value}\.(?<extension>json)" }
end

class SectorImportDirModel
  include DirModel::Model
  include DirModel::Import

  file :image, regex: -> { /Sectors\/Sector_(?<sector_id>.*)\.(?<extension>png|jpg)/i }

  has_one :metadata, SectorMetadataImportDirModel, foreign_key: :sector_name
  has_many :children, ZoneImportDirModel, foreign_key: :sector_name

  def sector_name
    "sector_#{sector_id}"
  end
end
