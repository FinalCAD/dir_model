module DirModel
  module Model
    module Files
      extend ActiveSupport::Concern

      included do
        include InheritedClassVar
        inherited_class_hash :files
      end

      module ClassMethods
        # @return [Array<Symbol>] file names for the row model
        def file_name
          files.keys.first
        end

        # @param [Symbol] file_name name of file to find option
        # @return [Hash] options for the file_name
        def options
          files[file_name]
        end

        # @param [Symbol] file_name name of file to find index
        # @return [Integer] index of the file_name
        def index(file_name)
          0
        end

        protected

        def file(file_name, options={})
          files_object.merge(file_name.to_sym => options)
          raise ArgumentError.new("You cannot define more of one file: but you can add relations, see README") if files.keys.size > 1
        end
      end
    end
  end
end
