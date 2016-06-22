require 'forwardable'

module DirModel
  module Import
    class Dir # File
      extend Forwardable

      attr_reader :index
      attr_reader :path
      attr_reader :import_dir_model_class
      attr_reader :context
      attr_reader :current_dir_model
      attr_reader :previous_dir_model

      def_delegators :@path, :end?

      def initialize(source_path, import_dir_model_class, context={})
        @path, @import_dir_model_class, @context = Path.new(source_path), import_dir_model_class, context.to_h.symbolize_keys
        reset
      end

      def reset
        path.reset!
        @index = -1
        @current_dir_model = nil
      end

      def each(context={})
        return to_enum(__callee__) unless block_given?

        while self.next(context)
          next if skip?
          yield current_dir_model
        end
      end

      def next(context={})
        return if end?

        context = context.to_h.reverse_merge(self.context)
        @previous_dir_model = current_dir_model
        @current_dir_model = import_dir_model_class.next(path, context, previous_dir_model)
        @index += 1
        @current_dir_model = @index = nil if end?

        current_dir_model
      end

      def first(context={})
        each(context).next
      rescue StopIteration
        nil
      end

      private

      def skip?
        !!current_dir_model.try(:skip?)
      end

    end
  end
end
