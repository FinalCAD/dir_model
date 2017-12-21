module DirModel
  module Model
    module Relations
      extend ActiveSupport::Concern
      included do
        inherited_class_hash :has_one_relationship
        inherited_class_hash :has_many_relationship
      end

      # @return [Boolean] returns true, if the instance is a child
      def child?
        !!parent
      end

      def has_relations?
        has_one? || has_many?
      end

      # Appends model to the parent and returns it
      #
      # @return [Model] return the child if it is valid, otherwise returns nil
      def append_dir_model(source_path, options={})
        relation_name = options[:relation_name]
        _options      = options[:relation_options]
        related_class = _options[:dir_model_class]
        foreign_key   = _options[:foreign_key]
        foreign_value = self.send(foreign_key)

        related_dir_model = related_class.new(source_path,
          options.reverse_merge(parent: self, foreign_value: foreign_value))

        return unless related_dir_model

        unless related_dir_model.skip?
          if public_send(relation_name).present?
            raise StandardError.new("There are more of one #{relation_name} => #{related_class} for #{self.class.name}")
          end
          public_send("#{relation_name}=", related_dir_model)
          related_dir_model
        else
          nil
        end
      end

      # Appends modeld to the parent and returns it
      #
      # @return [Model] return the child if it is valid, otherwise returns nil
      def append_dir_models(source_path, options={})
        relation_name = self.class.has_many_relationship.keys.first
        _options      = self.class.has_many_relationship.values.first
        related_class = _options[:dir_model_class]
        foreign_key   = _options[:foreign_key]
        foreign_value = self.send(foreign_key)

        related_dir_model = related_class.new(source_path,
          options.reverse_merge(parent: self, foreign_value: foreign_value))

        return unless related_dir_model

        unless related_dir_model.skip?
          public_send(relation_name) << related_dir_model
          related_dir_model
        else
          nil
        end
      end

      def has_one?
        false
      end

      def has_many?
        false
      end

      class_methods do
        # Defines a relationship between a dir model
        #
        # @param [Symbol] relation_name the name of the relation
        # @param [DirModel::Import] dir_model_class class of the relation
        def has_one(relation_name, dir_model_class, options)
          relation_name = relation_name.to_sym

          has_one_relationship_object.merge(relation_name => { dir_model_class: dir_model_class }.merge(options))

          define_method(:has_one?) do
            true
          end

          define_method(:has_one) do
            self.class.has_one_relationship
          end

          define_method("#{relation_name}=") do |value|
            instance_variable_set("@#{relation_name}", value)
          end

          define_method(relation_name) do
            instance_variable_get("@#{relation_name}")
          end
        end

        def has_one?
          !!@_has_one_relationship
        end

        # Defines a relationship between a dir model
        #
        # @param [Symbol] relation_name the name of the relation
        # @param [DirModel::Import] dir_model_class class of the relation
        # @param [Hash] basically for set :foreign_key
        def has_many(relation_name, dir_model_class, options)
          raise "for now, DirModel's has_many may only be called once" if @_has_many_relationship.present?
          relation_name = relation_name.to_sym

          has_many_relationship_object.merge(relation_name => { dir_model_class: dir_model_class }.merge(options))

          define_method(:has_many?) do
            true
          end

          define_method(relation_name) do
            #
            # equal to: @relation_name ||= []
            #
            variable_name = "@#{relation_name}"
            instance_variable_get(variable_name) || instance_variable_set(variable_name, [])
          end
        end

        def has_many?
          !!@_has_many_relationship
        end

        def has_relations?
          has_one? || has_many?
        end
      end
    end
  end
end
