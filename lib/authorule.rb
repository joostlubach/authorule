require 'active_support'
require 'active_support/core_ext'

module Authorule
  extend ActiveSupport::Autoload

  class PermissionResolutionError < RuntimeError
  end

  autoload :Permission
  autoload :Rule
  autoload :RuleBase
  autoload :PermissionAccessors
  autoload :PermissionHolder

  ######
  # Permission registration

    class DuplicatePermission < RuntimeError
    end

    @@permission_classes = {}
    mattr_reader :permission_classes

    def self.register(kind, klass)
      kind = kind.to_sym
      unless klass < Permission
        raise ArgumentError, "class #{klass.name} cannot be registered as a permission kind: it should be derived from Authorule::Permission"
      end
      if Authorule.permission_classes[kind]
        raise DuplicatePermission, "another permission class has already been registered for kind :#{kind}"
      end

      permission_classes[kind] = klass
    end

  ######
  # Permission resolution

    # Resolves a target. Tries all registered permission classes with a resolve block, and runs the target
    # through the block. If anythin is returned, it is passed into the constructor of that permission class.
    def self.resolve(target, action = nil)
      return target if target.is_a?(Authorule::Permission)

      permission_classes.values.each do |klass|
        next unless klass.resolve_block
        resolved = klass.resolve_block.call(target)

        return klass.new(resolved, action) if resolved
      end

      # If we got here, no schema returned a matching permission.
      raise PermissionResolutionError, "target #{target} could not be resolved into a permission"
    end

  ######
  # Permission listing

    # Retrieves all available permissions, organized by their kind, into a hash.
    #
    # @return [Hash<Symbol,Array<Permission>>] An organized list of permissions.
    def self.available_permissions
      available_permissions = {}

      permission_classes.each do |kind, klass|
        next unless klass.list_block

        available_permissions[kind] = []
        objects = klass.list_block.call

        objects.each do |object|
          available_permissions[kind] << klass.new(object)
        end
      end

      available_permissions
    end

end