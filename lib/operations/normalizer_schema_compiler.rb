# TODO, add support for array normalizers
# TODO, add support for array normalizers

# TODO, add support for normalizing scalars and array of scalars
# TODO, add support for normalizing scalars and array of scalars

# TODO, use normalizer type: integer, collection: true for scalars
# TODO, use normalizer type: integer, collection: true for scalars

module Operations
  class NormalizerSchemaCompiler
    def initialize(normalizer, collection: false)
      @normalizer = normalizer
      @collection = collection
    end

    def call
      format_property
    end

    def format_property
      type = normalizer.type == :hash ? format_nested : {type: normalizer.type}

      type = if collection || normalizer.collection
        {
          type: :array,
          member: [type]
        }
      else
        type
      end

      {types: [type], required: !normalizer.null}
    end

    def format_nested
      member = normalizer.schema.map do |property|
        [property.path, NormalizerSchemaCompiler.new(property).call]
      end.to_h

      {
        type: :hash,
        member: member
      }
    end

    private

    attr_reader :normalizer, :collection
  end
end
