module Authorule

  # Provides methods 'may?', 'may_access?' and their negative counterparts. You must make sure
  # to implement method 'has_permission?' in your class.
  module PermissionAccessors

    # Determines whether a holder in this group may perform the specified action on the specified target.
    #
    # @param [#to_s] action
    #   The action to perform. The available actions differ per permissions. The full list can be found
    #   in {UI::Permission}.
    # @param target
    #   The target the holder wishes to operate on. This target may be any object and is passed to the UI
    #   permission checker as is, which will convert it into a permission path.
    def may?(action, target)
      permission = Authorule.resolve(target, action)
      unless permission.available_actions.try(:include?, action)
        raise ArgumentError, "action :#{action} not available for permission of kind :#{permission.class.kind}"
      end

      has_permission? permission
    end

    # Checks a permission without querying a specific action.
    # @see #may?
    def may_access?(target)
      permission = Authorule.resolve(target)
      has_permission? permission
    end

    # Determines whether a holder may not perform the specified action on the specified target.
    # @see #may?
    def may_not?(action, target)
      !may?(action, target)
    end

    # Determines whether a holder may not access the specified target.
    # @see #may_not?
    # @see #may?
    def may_not_access?(target)
      !may_access?(target)
    end



  end
end