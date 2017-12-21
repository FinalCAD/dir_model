# DirModel

Import and export directories with an ORM-like interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dir_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dir_model

## Usage

### Import

```ruby
class BasicDirModel
  include DirModel::Model

  file :image, regex: -> { /Zones\/Sector_(?<sector_id>.*)\/Zone_(?<zone_id>.*)\.(?<extension>png|jpg)/i }
end
```

named matches are available under `matches[:sector_id]` or directly when you calling `sector_id`

An implementation possible of Import

```ruby
class BasicImportDirModel < BasicDirModel
  include DirModel::Import

  protected

  def model
    Project.find(context[:project_id]).sectors.find(sector_id).zones.find(zone_id)
  end
end
```

You can have access at the file through

`BasicImportDirModel.new(source_path, project_id: 42).image`

#### Relation

### Has One

A dir_model can have a relation like `has_one` basically is

```ruby
class ChildImportDirModel
  include DirModel::Model
  include DirModel::Import
  file :metadata, regex: ->(foreign_value) { "Zones\/(?<sector_name>#{foreign_value})\/Zone_(?<zone_id>.*)\.(?<extension>json)" }
end
```

```ruby
class ParentImportDirModel < BasicImportDirModel
  has_one :dependency, ChildImportDirModel, foreign_key: :sector_name

  def sector_name
    "sector_#{sector_id}"
  end
end
```

```ruby
parent_instance.dependency # => ChildImportDirModel
child.parent # => parent_instance
```

### Has Many

You can define an `has_many` relation with another `DirModel`, is this case syntax is a bit different you have to pass a `foreign_key`, basically the name of the method should return a value will be replace in the regex in children relationships, like examples below

NOTE regex on child pass explicitly the value

```ruby
class ZoneDirModel
  include DirModel::Model
  include DirModel::Import
  file :image, regex: ->(foreign_value) { "Zones\/(?<sector_name>#{foreign_value})\/Zone_(?<zone_id>.*)\.(?<extension>png|jpg)" }
end
```

```ruby
class SectorDirModel
  include DirModel::Model
  file :image, regex: -> { /Sectors\/Sector_(?<sector_id>.*)\.(?<extension>png|jpg)/i }
end
```

```ruby
class SectorImportDirModel < SectorDirModel
  include DirModel::Import

  has_many :dependencies, ZoneDirModel, foreign_key: :sector_name

  def sector_name
    'sector_1'
  end
end
```

### Export

```ruby
class BasicDirModel
  include DirModel::Model

  file :image, path: -> { "#{dir}/#{sub_dir}" }, name: -> { image_name }
end
```

`path` and `name` can take Proc or String if doesn't have any interpolation.

If you don't know the extension of your image it will be automatically discover, but this works only for image so if you send, for instance, a json file you have to explicitly provide extension on the `:name` options

```ruby
class BasicExportDirModel < BasicDirModel
  include DirModel::Export

  def dir
    'Sectors'
  end

  def sub_dir
    source_model.sector_name
  end

  def image_name
    source_model.zone_name
  end

  def image
    source_model.zone
  end

  def image_extension
    '.png'
  end
end

fixture_models = [
  OpenStruct.new({
    id: 42,
    sector_name: 'sector_name',
    zone_name: 'zone_name',
    zone: File.new('spec/fixtures/image.png'),
  })
]

exporter = DirModel::Export::AggregateDir.new

exporter.generate do |dir|
  models.each do |model|
    dir.append_model(BasicExportDirModel, model)
  end
end

exporter.dir_path # => path of generated dir .../Sectors
```

an skip? method based on the name of file :image is create, this method is named `image_skip?`

default implementation
```
def skip?
  image.present?
end
```
NOTE Safe to override on your Exporter

In fact this is equivalent to

```
def skip?
  source_model.zone.present?
end
```

by default Exporter provide a link between `source_model` and your `file` like
```
def image
  source_model.image
end
```
NOTE Safe to override on your Exporter

In fact this play well with carrierwave and provide for you automatically
```
def image
  source_model.image.file
end
```

as well Exporter provide extension method only for carrierwave uploader
```
def image_extension
  source_model.image.file.extension
end
```
Otherwise return nil, safe to override on your Exporter
