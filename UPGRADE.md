# Upgrading

# Upgrading from 0.6.2 to 0.7.0

* Change the manner of call AggregateDir like

From

```
exporter = DirModel::Export::AggregateDir.new(BasicExportDirModel)

exporter.generate do |dir|
  models.each do |model|
    dir << model
  end
end
```


To

```
exporter = DirModel::Export::AggregateDir.new

exporter.generate do |dir|
  models.each do |model|
    dir.append_model(BasicExportDirModel, model)
  end
end
```

Now you can compose like

```
exporter = DirModel::Export::AggregateDir.new

exporter.generate do |dir|
  models.each do |model|
    dir.append_model(SectorExportDirModel, model)
  end
end.generate do |dir|
  models.each do |model|
    dir.append_model(ZoneExportDirModel, model)
  end
end
```

# Upgrading from 0.5.1 to 0.6.0

* relation need to have a foreign_key and dir_model related need to have a regex with the foreign_key in params

# Upgrading from 0.4.0 to 0.5.0

* Ensure you have only one definition of `file:` by dir_model

# Upgrading from 0.2.0 to 0.3.0

* Model is now a module you have to change include from `include DirModel` to `include DirModel::Model`

# Upgrading from 0.1.0 to 0.2.0

You have to change

```
def _generate
  mk_chdir "level1" do
    mk_chdir "level2" do
      copy_file :zone_image
    end
  end
end
```

for a DirModel

```
class BasicDirModel
  include DirModel

  file :image, path: -> { "#{dir}/#{sub_dir}" }, name: -> { "#{image_name}.png" }
end
```
see the README
