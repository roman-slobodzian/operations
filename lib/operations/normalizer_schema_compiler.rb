module Operations
  class NormalizerSchemaCompiler
    def initialize(normalizer)
      @normalizer = normalizer
    end

    def call
      format_nested(normalizer)
    end

    def format_property(property)
      type = property.type == :hash ? format_nested(property) : {type: property.type}

      {types: [type], required: !property.null}
    end

    def format_nested(normalizer)
      member = normalizer.schema.map do |property|
        [property.path, format_property(property)]
      end.to_h

      type = {
        type: :hash,
        member: member
      }

      if normalizer.collection
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
