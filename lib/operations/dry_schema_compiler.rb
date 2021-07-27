# Is taken from https://github.com/dry-rb/dry-schema/blob/d0f601c370f6e399e83067cbf321947904d735fd/lib/dry/schema/extensions/info/schema_compiler.rb
# Had the issue https://github.com/dry-rb/dry-schema/issues/367
module Operations
  class DrySchemaCompiler
    TYPESCRIPT_TYPE_MAP = {
      array?: :array,
      hash?: :hash,
      bool?: :boolean,
      date?: :string,
      date_time?: :string,
      decimal?: :number,
      float?: :number,
      int?: :number,
      nil?: :null,
      str?: :string,
      time?: :string
    }.freeze

    attr_reader :keys, :each_entered, :type_map

    def initialize(type_map: TYPESCRIPT_TYPE_MAP)
      @keys = {}
      @each_entered = false
      @type_map = type_map
    end

    def to_h
      {keys: keys}
    end

    def call(ast)
      visit(ast)
    end

    def visit(node, opts = {})
      meth, rest = node
      public_send(:"visit_#{meth}", rest, opts)
    end

    def visit_set(node, opts = {})
      target = (key = opts[:key]) ? self.class.new : self

      node.map { |child| target.visit(child, {}) }

      return unless key

      keys[key][:type] << if opts[:member]
        {
          type: :array,
          member: [type: :hash, member: target.keys]
        }
      else
        {
          type: :hash,
          member: target.keys
        }
      end
    end

    def visit_and(node, opts = {})
      left, right = node

      visit(left, opts)
      visit(right, opts)
    end

    def visit_not(node, opts = {})
      visit(node, opts)
    end

    def visit_or(node, opts = {})
      left, right = node

      visit(left, opts)
      visit(right, opts)
    end

    def visit_implication(node, opts = {})
      node.each do |el|
        visit(el, opts.merge(required: false))
      end
    end

    def visit_each(node, opts = {})
      self.each_entered = true
      visit(node, opts.merge(member: true))
    end

    def visit_key(node, opts = {})
      name, rest = node
      visit(rest, opts.merge(key: name, required: true))
    end

    def visit_predicate(node, opts = {})
      name, rest = node

      case name
      when :key?
        keys[rest[0][1]] = {required: opts.fetch(:required, true)}
      else
        set_key_type(name, opts)
      end
    end

    private

    attr_writer :each_entered

    def set_key_type(predicate, opts)
      type = type_map[predicate]

      return unless type

      key = opts[:key]

      keys[key][:type] = [] unless keys[key][:type]

      return if %i[hash array].include?(type)

      formatted_type = {type: type}

      if opts[:member]
        if each_entered
          keys[key][:type] << {type: :array, member: [formatted_type]}
          self.each_entered = false
        else
          keys[key][:type].last[:member] << formatted_type
        end
      else
        keys[key][:type] << formatted_type
      end
    end
  end
end
