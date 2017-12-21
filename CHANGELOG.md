### VERSION 0.7.0

* Change the design of `AggregateDir` to make it composable 

### VERSION 0.6.2

* Removing escaping from the code, so now `foreign_key` should be escaped on the caller, basically user `Regexp.quote` :

```
class ParentImportDirModel < BasicImportDirModel
  has_one :dependency, ChildImportDirModel, foreign_key: :sector_name

  def sector_name
    "sector_#{Regexp.quote(sector_id)}"
  end
end
```

### VERSION 0.6.1

* escape special characters on foreign key values. Due of this relations weren't be found.

### VERSION 0.6.0

* Fix relations

### VERSION 0.5.1

* Add relation has_many to a dir_model

### VERSION 0.5.0

* Add relation has_one to a dir_model
* `file:` must be unique, you can't defined several file in the same dir_model
* Simplification of `lib/dir_model/import.rb`

### VERSION 0.4.0
### VERSION 0.3.4
### VERSION 0.3.3
### VERSION 0.3.2

### VERSION 0.3.1

* Technical changes, Simplication of Path, use Array skill to give previous, current and next Path instead of using Enumerator

### VERSION 0.3.0

* Add Import feature

### VERSION 0.2.0

* Apply [CsvRowModel](https://github.com/FinalCAD/csv_row_model) pattern for export.

### VERSION 0.1.0

* First extraction
