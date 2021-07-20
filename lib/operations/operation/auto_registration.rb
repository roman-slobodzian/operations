# Auto registration is controlled from the app to be easily replaced by something else
module Operations
  class Operation
    module AutoRegistration
      extend ActiveSupport::Concern

      included do
        thread_cattr_accessor :operations, default: []
      end

      class_methods do
        def inherited(base)
          super
          operations << base
        end
      end
    end
  end
end
