# Authorule

Rule based authorization library.

[<img src="https://secure.travis-ci.org/yoazt/authorule.png?branch=master" alt="Build Status" />](http://travis-ci.org/yoazt/authorule)

## Installation

Add this line to your application's Gemfile:

    gem 'authorule'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authorule

## Usage

### Write rule model

Write a permission rule model. By default, `Authorule` expects this to be called `PermissionRule`. You may add any associations in the class, but this is not required by this gem.

    class PermissionRule < ActiveRecord::Base
      include Authorule::Rule

      belongs_to :user
    end

Use the following migration for this class (TODO: write a generator):

    class CreatePermissionRules < ActiveRecord::Migration
      def change
        create_table :permission_rules do |t|
          t.boolean :allow, :default => true
          t.string :kind, :limit => 20
          t.string :name, :limit => 80
          t.string :action, :limit => 20

          # --> Add any other columns here.
        end
      end
    end

### Write permission holder

Write a permission holder model. This is typically a `User` object. Include `Authorule::PermissionHolder` into this class, and call `is_permission_holder!`.

    class User < ActiveRecord::Base
      include Authorule::PermissionHolder

      is_permission_holder!
    end

This creates an association and a rule base accessor. By default, it is assumed that the rule class is called `PermissionRule`.

### Write a custom permission class

Write a permission class. Each permission class should at a minimum:

1. Register itself under a name.
2. Provide a way to resolve any argument into a permission target.
3. Provide a way to list all permission targets.

A permission target is the object that you wish to secure using the permission. The following example is a permission that secures access to any ActiveRecord object. The target is the class (e.g. 'Allow user X to access Active Record class Y.'), but the permission can also resolve model instances.

    class ResourcePermission < Authorule::Permission

      # Register under name :resource.
      register :resource

      # Resolution.
      resolve do |arg|
        if arg.is_a?(ActiveRecord::Base)
          arg.class
        elsif arg.is_a?(Class) && arg < ActiveRecord::Base
          arg
        end
      end

      list do
        classes = []
        Dir[ Rails.root + 'app/models' + '*.rb' ].each do |file|
          klass = File.basename(file, '.rb').camelize.safe_constantize
          classes << klass if klass
        end
        classes
      end

    end

### Checking permissions

You can now give any user a set of rules, e.g.:

1. Allow access to everything
2. Deny access to ActiveRecord class 'Account'

This allows the user to access all other ActiveRecord classes (and their objects).

To check a permission, you can call:

    User.may_access?(Account)

or

    User.may_access?(Account.new)

(because it resolves into a class), or the equivalent

    permission = Authorule.resolve(Account.new)
    User.has_permission?(permission)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
