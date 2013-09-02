module Authorule

  # A permission rule base. This class performs the heart of the permission checking algorithms.
  #
  # == Algorithm description
  #
  # A rule base is always queried for one permission. The result should be whether it is allowed or denied.
  #
  # When running a permission through the rule base, the permission itself, and all dependent permissions
  # are run through the rule base. See {Permission#dependencies} for more info about permission dependencies.
  #
  # The last defined rule (i.e. the rule with the highest priority) matching *any* of the checks is taken
  # as the deciding rule.
  #
  # == Example
  #
  # Let's illustrate the given algorithm with an example. Let's say we have the following permissions, taken
  # from the UI library:
  #
  # * +SpacePermission+: a permission to access a certain UI space (a collection of UI resources)
  # * +ResourcePermission+: a permission to access a certain resource
  #
  # A resource permission has a dependency on its corresponding space permission. In other words, a user must
  # have access to the resource's space as well as the resource itself for it to be accessible.
  #
  # Then, we consider a rule base with the following rules:
  #
  # 1. Deny all
  # 2. Allow space 'CRM'
  # 3. Deny resource 'Account'
  #
  # Now, we need to check whether the user may view the resource 'Account':
  #
  #   permission = ResourcePermission.new(account_resource, :view)
  #
  # When resolving all dependencies, we end up with the following list of permissions:
  #
  #   permissions = permission.resolve_dependencies
  #   # => [ SpacePermission.new(crm_space), ResourcePermission.new(account_resource, :view) ]
  #
  # Both of these permissions are now run through the rule base. The first permission is matched by rules
  # 1 (all) and 2 (space 'CRM'). The second permission is matched by rules 1 (all) and 3 (resource 'Account').
  # The last defined rule is the third rule. As it is set to deny access, the resulting access to the permission
  # is denied. This makes sense because we deny it last in line.
  #
  # If however, the rule base were to switch around 2 and 3, the rule base would look as follows:
  #
  # 1. Deny all
  # 2. Deny resource 'Account'
  # 3. Allow space 'CRM'
  #
  # Now, the first permission will be matched by rule 3, which is the last rule to match. As it is set to allow
  # access, the resulting access to the permission is allowed. As you can see, the second rule is overruled by the
  # more generic rule 3.
  class RuleBase

    ######
    # Initialization

      # Initializes the rule base with the given rules.
      def initialize(rules)
        @rules = rules.to_a
        @index = build_index
      end

    ######
    # Attributes

      # @!attribute [r] rules
      # @return [Array] The rules in the rule base.
      attr_reader :rules

    ######
    # Index

      # Builds an index that maps a permission key into a rule index.
      def build_index
        index = {}

        rules.each_with_index do |rule, idx|
          key = rule.key

          # Use this to make sure any duplicate entry uses the maximum index (i.e. last defined rule).
          index[key] = [ index[key], idx ].compact.max
        end
        index
      end
      private :build_index

    ######
    # Runner

      # Runs the given permission through the rule base.
      #
      # @return [true|false] +true+ if the permission is allowed, +false+ if not.
      def run(permission)
        last_rule_index = nil

        permission.with_dependencies.each do |permission|
          keys = permission_checks(permission)

          # Compare the current index with the indices of all rules that match and take the maximum.
          last_rule_index = ([ last_rule_index ] + keys.map{ |key| @index[key] }.flatten).compact.max
        end

        if last_rule_index
          rules[last_rule_index].allow?
        else
          # The default policy is to deny the permission if no rules match.
          false
        end
      end

      # Determines all permission checks for the given permission.
      def permission_checks(permission)
        keys = []

        if permission.action
          # Add '<kind>:<name>:<action>'
          keys << [ permission.kind, permission.name, permission.action ].join(':')

          # Add '<kind>:all(:<action>'
          keys << [ permission.kind, 'all', permission.action ].join(':')
        end

        # Add '<kind>:<name>'
        keys << [ permission.kind, permission.name ].join(':')

        # Add '<kind>:all'
        keys << [ permission.kind, 'all' ].join(':')

        # Add 'all'
        keys << 'all'

        keys
      end
      private :permission_checks

  end

end