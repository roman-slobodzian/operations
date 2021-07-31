module Operations
  class NormalizerSchemaCompiler
    def initialize(normalizer)
      @normalizer = normalizer
    end

    def call
      normalizer.schema.map do |property|
        [property.path, format_property(property)]
      end.to_h
    end

    def format_property(property)
      type = property.type == :hash ? format_nested(property) : {type: property.type}

      {type: [type], required: !property.null}
    end

    def format_nested(property)
      member = NormalizerSchemaCompiler.new(property).call
      type = {
        type: :hash,
        member: member
      }

      if property.collection
        {
          type: :array,
          member: [type]
        }
      else
        type
      end
    end

    private

    attr_reader :normalizer
  end
end
