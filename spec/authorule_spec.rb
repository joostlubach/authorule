require 'spec_helper'

describe Authorule do

  # Stub the permission registry to prevent messing with the actual set up.
  let(:registry) { Hash.new }
  before { Authorule.stub(:permission_classes).and_return(registry) }

  ######
  # Registration

    describe '#register' do

      it "should allow any class derived from Permission to be registered" do
        klass = Class.new(Authorule::Permission)

        Authorule.register :test, klass
        registry[:test].should == klass
      end

      it "should not allow any other class to be registered" do
        klass = Class.new
        expect { Authorule.register :test, klass }.to raise_error(ArgumentError)
      end

      it "should not allow a registration for the same kind twice" do
        klass = Class.new(Authorule::Permission)

        Authorule.register :test, klass
        expect { Authorule.register :test, klass }.to raise_error(Authorule::DuplicatePermission)
      end


    end

    describe 'Authorule::Permission.kind' do

      # A bit outside the scope of this file, but it's part of registration.
      it "should allow any Authorule::Permission derived class to register itself" do
        klass = Class.new(Authorule::Permission)

        Authorule.should_receive(:register).with(:test, klass)
        klass.class_eval { register :test }
      end

    end

  ######
  # Resolution & available permissions

    describe '.resolve' do
      let(:permission_class1) { Class.new(Authorule::Permission) }
      let(:permission_class2) { Class.new(Authorule::Permission) }
      before do
        Authorule.stub(:permission_classes).and_return({})
        Authorule.register :permission1, permission_class1
        Authorule.register :permission2, permission_class2
      end

      it "should resolve any instance of Authorule::Permission into itself" do
        permission = Authorule::Permission.new(double())
        Authorule.resolve(permission).should be(permission)
      end

      it "should raise PermissionResolutionError if no permission classes were registered" do
        Authorule.stub(:permission_classes).and_return({})
        expect { Authorule.resolve(double()) }.to raise_error(Authorule::PermissionResolutionError)
      end

      it "should raise PermissionResolutionError if no permission classes with resolution blocks were registered" do
        expect { Authorule.resolve(double()) }.to raise_error(Authorule::PermissionResolutionError)
      end

      it "should run through all registered permission classes and try to resolve the target - the first one found should be instantiated" do
        target = double()
        resolved = double()
        permission_class1.stub(:resolve_block).and_return(->(tgt) { tgt != target ? resolved : nil })
        permission_class2.stub(:resolve_block).and_return(->(tgt) { tgt == target ? resolved : nil })

        permission = double()
        permission_class2.should_receive(:new).with(resolved, :view).and_return(permission)

        Authorule.resolve(target, :view).should be(permission)
      end
    end

    describe '.available_permissions' do
      let(:permission_class1) { Class.new(Authorule::Permission) }
      let(:permission_class2) { Class.new(Authorule::Permission) }
      before do
        Authorule.stub(:permission_classes).and_return({})
        Authorule.register :permission1, permission_class1
        Authorule.register :permission2, permission_class2
      end

      it "should include an item for each permission class having a list block" do
        targets = [ :one, :two ]
        permission_class1.stub(:list_block).and_return(proc { targets })

        permissions = Authorule.available_permissions
        permissions.should have(1).item

        permissions[:permission1].should be_a(Array)
        permissions[:permission1].should have(2).items

        permissions[:permission1][0].should be_a(permission_class1)
        permissions[:permission1][0].object.should == :one
        permissions[:permission1][1].should be_a(permission_class1)
        permissions[:permission1][1].object.should == :two
      end
    end

end