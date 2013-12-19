module Curate
  module FormClassBuilder
    module_function
    def build(name, config)
      form_class = Class.new do
        include Virtus.model
        include ActiveModel::Validations
        class_attribute :fieldsets, instance_writer: false, instance_reader: false
        class_attribute :work_type
        class_attribute :finalizer_config, instance_writer: false
        self.fieldsets = {}

        attr_reader :controller
        def initialize(controller)
          @controller = controller
          super()
        end

        def fieldsets
          @fieldsets ||= self.class.fieldsets.map {|name, attribute_names| FormFieldset.new(self, name, attribute_names)}
        end

        attr_accessor :minted_identifier
        protected :minted_identifier=
        def inspect
          "<FinalizedForm/#{work_type}#{persisted? ? " ID: " << minted_identifier : ' '}{\n\tattributes: #{attributes.inspect},\n\n\tfinalizer_config: #{finalizer_config.inspect}\n}>"
        end

        def save
          valid? ? on_save : false
        end

        def on_save
          true
        end

        def to_param
          minted_identifier
        end

        def to_key
          persisted? ? [minted_identifier] : nil
        end

        def persisted?
          minted_identifier.present?
        end

      end
      form_class.finalizer_config = config
      form_class.work_type = name
      form_class
    end
  end
end
