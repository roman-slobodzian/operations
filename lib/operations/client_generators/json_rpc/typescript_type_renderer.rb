module Operations
  module ClientGenerators
    module JsonRpc
      class TypeScriptTypeRenderer
        def call(type)
          type_to_ts(type)
        end

        private

        def type_to_ts(type)
          case type[:type]
          when :hash
            hash_to_ts(type)
          when :array
            "Array<#{types_to_ts(type[:member])}>"
          else
            type[:type]
          end
        end

        def types_to_ts(types)
          types.map { |type| type_to_ts(type) }.join(" | ")
        end

        def hash_to_ts(type)
          hash_type = type[:member].map do |name, key_type|
            "#{name}#{key_type[:required] ? "" : "?"}: #{types_to_ts(key_type[:type])}"
          end.join("\n")

          "{\n#{hash_type}\n}"
        end
      end
    end
  end
end
