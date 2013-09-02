module Authorule

  # Makes any ActiveModel/ActiveRecord-like class a UI permission holder.
  #
  # == Usage
  #
  #   class User
  #     include Authorule::PermissionHolder
  #     is_permission_holder!
  #   end
  #
  # * A (has many) +permission_rules+ association is added to the model (though the
  #   name may be changed in the {.is_permission_holder!} method).
  # * A {#may?} and {#may_not?} method is added.
  module PermissionHolder
    extend ActiveSupport::Concern

    include PermissionAccessors

    module ClassMethods

      # Marks this class as a permission holder with the given options.
      #
      # @option options [#to_sym] association_name (:permission_rules)
      #   The name of the permission rules association.
      def is_permission_holder!(options = {})
        association_name = options[:association_name] || :permission_rules

        class_eval <<-RUBY, __FILE__, __LINE__+1
          has_many :#{association_name}

          def permission_rule_base(reload = false)
            @permission_rule_base = nil if reload
            @permission_rule_base ||= RuleBase.new(#{association_name}(true))
          end
        RUBY
      end

    end

    ######
    # has_permission?

      # Determines whether this holder has the given permission by running it through his rule base.
      def has_permission?(permission)
        unless respond_to?(:permission_rule_base)
          raise "class not set up as permission holder, call is_permission_holder! first"
        end

        permission_rule_base.run permission
      end

  end

end
