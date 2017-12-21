require 'active_support/hash_with_indifferent_access'

module DirModel
  module Export
    class AggregateDir
      include Utils

      attr_reader :context, :dir_path

      # @param [Export] export_model export model class
      def initialize(context={})
        @context  = context.to_h.symbolize_keys
        @dir_path = Dir.mktmpdir
      end

      # Add a row_model to the
      # @param [] source_model the source model of the export file model
      # @param [Hash] context the extra context given to the instance of the file model
      def append_model(export_dir_model_class, source_model, context={})
        source_path = export_dir_model_class.new(source_model, context.reverse_merge(self.context)).path
        FileUtils.cp_r Dir.glob("#{source_path}/*"), dir_path
      end

      def generate
        yield self
        self
      end

      def files
        Dir["#{@dir_path}/**/*"].select { |f| File.file?(f) }
      end
    end
  end
end
