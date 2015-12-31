module DirModel
  module Import
    extend ActiveSupport::Concern

    attr_reader :context, :source_path, :index, :previous, :foreign_value

    def initialize(path, options={})
      super # set parent
      @source_path, @context = path, OpenStruct.new(options[:context])
      @index, @previous      = options[:index], options[:previous].try(:dup)
      @load_state            = :ghost
      @foreign_value         = options[:foreign_value]
    end

    def skip?
      load
      !@_match
    end

    def method_missing(name, *args, &block)
      load
      @_match[name]
    rescue
      super
    end

    module ClassMethods
      def next(path, context={}, previous=nil)
        return if path.end?

        path.read_path
        dir_model = new(path.current_path, index: path.index, context: context, previous: previous)
        find_relations(dir_model, path, context)

        dir_model
      end

      private

      def find_relations(dir_model, path, context)
        unless dir_model.skip?
          if dir_model.has_relations?
            if dir_model.has_one?
              child = search(path, context) do |_path, _context|
                dir_model.append_dir_model(_path.current_path, index: _path.index, context: _context)
              end.first
              find_relations(child, path, context) if child
            end
            if dir_model.has_many?
              children = search(path, context) do |_path, _context|
                dir_model.append_dir_models(_path.current_path, index: _path.index, context: _context)
              end
              children.each { |_child| find_relations(_child, path, context) }
            end
          end
        end
      end

      def search(path, context)
        return unless block_given?

        dir_models = []
        current_position = path.index
        path.rewind
        while !path.end? do
          path.read_path
          dir_models << yield(path, context)
        end
        path.set_position(current_position)
        dir_models.uniq.compact
      end
    end

    private

    attr_reader :load_state

    def match?
      return if load_state == :loaded
      @_match = find_match.tap { @load_state = :loaded }
    end
    alias_method :load, :match?

    def find_match
      @_match = (source_path||'').match(get_regexp)
    end

    def get_regexp
      if foreign_value
        Regexp.new(self.class.options[:regex].call(foreign_value), Regexp::IGNORECASE)
      else
        self.class.options[:regex].call
      end
    end
  end
end
