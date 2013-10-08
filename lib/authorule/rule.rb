module Authorule

  # A permission rule. Each rule allows or denies the permission holder one permission.
  #
  # == Usage
  #
  # Create a model class, and include this mixin into it, e.g.
  #
  #   class PermissionRule < ActiveRecord::Base
  #     include Authorule::Rule
  #
  #     belongs_to :user
  #   end
  #
  # @see RuleBase
  module Rule
    extend ActiveSupport::Concern

    ######
    # Attributes & validations

      included do
        validates_inclusion_of :allow, :in => [ true, false ]
        validates_presence_of :kind, :name

        validates_length_of :kind, :maximum => 20
        validates_length_of :name, :maximum => 80
        validates_length_of :action, :maximum => 20, :allow_blank => true
      end

    ######
    # Rule creation accessors

      # Builds an allow rule for the given kind and name.
      def self.allow(kind, name, attributes = {})
        new attributes.merge(:kind => kind, :name => name, :allow => true)
      end

      # Creates an allow rule for the given kind and name.
      def self.allow!(kind, name, attributes = {})
        allow(kind, name, attributes).save
      end

      # Builds a deny rule for the given kind and name.
      def self.deny(kind, name, attributes = {})
        new attributes.merge(:kind => kind, :name => name, :allow => false)
      end

      # Creates a deny rule for the given kind and name.
      def self.deny!(kind, name, attributes = {})
        deny(kind, name, attributes).save
      end

      # Builds an 'allow all' rule.
      #
      # == Examples
      #
      #   Rule.allow_all              # => kind 'all', name 'all'
      #   Rule.allow_all(:resource)   # => kind 'resource', name 'all'
      def self.allow_all(kind = :all, attributes = {})
        new attributes.merge(:kind => kind, :name => 'all', :allow => true)
      end

      # Creates an 'allow all' rule.
      # @see .allow_all
      def self.allow_all!(kind = :all, attributes = {})
        allow_all(kind, attributes).save
      end

      # Creates a 'deny all' rule.
      #
      # == Examples
      #
      #   Rule.deny_all              # => kind 'all', name 'all'
      #   Rule.deny_all(:resource)   # => kind 'resource', name 'all'
      def self.deny_all(kind = :all, attributes = {})
        new attributes.merge(:kind => kind, :name => 'all', :allow => false)
      end

      # Creates an 'deny all' rule.
      # @see .deny_all
      def self.deny_all!(kind = :all, attributes = {})
        allow_all(kind, attributes).save
      end

    ######
    # Rule key

      # @!attribute [r] key
      # @return [String] A unique key identifying this rule.
      def key
        if kind == 'all'
          'all'
        else
          [ kind, name, action ].compact.join(':')
        end
      end

    ######
    # Misc

      def to_display
        key
      end

  end

end