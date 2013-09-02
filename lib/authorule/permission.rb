module Authorule

  # A permission. This is an object that can be used to check if someone has access to a certain permissable.
  #
  # Note: do not confuse a permission with a {PermissionRule} or {PermissionRuleBase}. This class doesn't indicate
  # that a user has been granted a permission. It simply encapsulates a permission query.
  #
  # This class should also not be confused with a {CustomPermission}, which is an application-defined custom
  # permission.
  #
  # == Usage
  #
  #   permission = Permission.resolve(Campaign, :destroy)
  #   @user.has_permission?(permission) # Granted that @user < UI::PermissionHolder
  #
  # Or even simpler:
  #
  #   @user.may?(:destroy, @campaign)
  #
  # == Object resolution
  #
  # Any object can be converted into a permission, if a suitable {Schema} can be found. For example, any UI resource
  # can be resolved into a resource permission, but also any resource model class or even resource symbol. This
  # allows for the following equivalent calls:
  #
  #   @user.may?(:destroy, UI.application.resources[:campaign])
  #   @user.may?(:destroy, @campaign)
  #   @user.may?(:destroy, Campaign)
  #   @user.may?(:destroy, :campaign)
  #
  # The UI library defines a few schemas, for example one for resource permissions, and one for UI space permissions.
  # There is also a custom permission schema - allowing the application designer to define additional permissions.
  # These can be referred to throughout the UI library.
  #
  # @see PermissionHolder
  # @see RuleBase
  # @see Rule
  class Permission

    ######
    # Initialization

      # Initializes a new permission.
      #
      # @param object
      #    The object of the permission.
      # @param [Symbol|nil] action
      #   The action the user wishes to perform.
      def initialize(object, action = nil)
        @object = object
        @action = action.try(:to_sym)
      end

    ######
    # Attributes

      # @!attribute [r] object
      # @return [Symbol] The object of the permission.
      attr_reader :object

      # @!attribute [r] action
      # @return [Symbol|nil] The action the user wishes to perform.
      attr_reader :action

      # @!attribute [r] kind
      # @return [Symbol] The kind of permission. This is delegated to the current class.
      def kind
        self.class.kind
      end

      # @!attribute [r] name
      # @return [String] The name of the permission. This is delegated to {#object}.
      def name
        object.name
      end

      # @!attribute [r] available_actions
      # @return [Array] The available actions for the permission.
      def available_actions
        []
      end

    ######
    # Dependencies

      # Retrieves an array of permissions consisting of dependencies and the permission itself.
      def with_dependencies
        dependencies + [ self ]
      end

      # Resolves dependencies for this permission. To be implemented by subclasses.
      def dependencies
        []
      end

    ######
    # Registration & metadata

      class << self

        attr_reader :kind, :resolve_block, :list_block

        # Registers a permission class under a specific kind.
        def register(kind)
          Authorule.register kind, self
          @kind = kind
        end

        # Defines a block that resolves any argument into a suitable permission target.
        def resolve(&block)
          @resolve_block = block
        end

        # Defines a block that lists all suitable permission targets in the application.
        def list(&block)
          @list_block = block
        end

      end

  end

end