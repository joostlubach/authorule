require 'spec_helper'

describe Authorule::PermissionHolder do

  let(:model) do
    Class.new(ActiveRecord::Base) do
      include Authorule::PermissionHolder
      is_permission_holder!
    end
  end
  let(:record) do
    record = Class.new()
    record.class.send(:include, Authorule::PermissionHolder)
    record.class.stub(:has_many)
    record.class.is_permission_holder!
    record
  end

  it "should add a 'rules' association" do
    association = model.reflect_on_association(:permission_rules)

    association.should_not be_nil
    association.macro.should == :has_many
  end

  describe '#permission_rule_base' do

    it "should return a rule base based on the permission rules for the holder" do
      rules = []
      record.should_receive(:permission_rules).with(true).and_return(rules)

      record.permission_rule_base.should be_a(Authorule::RuleBase)
      record.permission_rule_base.rules.should be(rules)
    end

    it "should cache its value" do
      rules = []
      record.should_receive(:permission_rules).with(true).once.and_return(rules)

      base = record.permission_rule_base
      record.permission_rule_base.should be(base)
    end

    it "should not cache its value when reload=false" do
      rules = []
      record.should_receive(:permission_rules).with(true).twice.and_return(rules)

      base = record.permission_rule_base
      record.permission_rule_base(true).should_not be(base)
    end

  end

  describe 'has_permission?' do
    let(:rule_base) { double() }
    before { record.should_receive(:permission_rule_base).and_return(rule_base) }

    it "should run the given permission through the rule base, and return true if that returns true" do
      permission = double()
      rule_base.should_receive(:run).with(permission).and_return(true)
      record.should have_permission(permission)
    end

    it "should run the given permission through the rule base, and return false if that returns false" do
      permission = double()
      rule_base.should_receive(:run).with(permission).and_return(false)
      record.should_not have_permission(permission)
    end
  end

  describe 'may_* methods' do

    let(:target) { double() }
    let(:permission) { double() }

    describe 'may_access?' do

      it "should resolve the given argument to a permission, check it, and return what it returns" do
        result = double()

        Authorule.should_receive(:resolve).with(target).and_return(permission)
        record.should_receive(:has_permission?).with(permission).and_return(result)
        record.may_access?(target).should be(result)
      end

    end

    describe 'may?' do

      before { Authorule.should_receive(:resolve).with(target, :view).and_return(permission) }

      context "with a valid action" do
        it "should resolve the given argument to a permission, check it, and return what it returns" do
          permission.should_receive(:available_actions).and_return([:view])

          result = double()
          record.should_receive(:has_permission?).with(permission).and_return(result)

          record.may?(:view, target).should be(result)
        end
      end

      context "with an invalid action" do
        it "should raise an error" do
          permission.should_receive(:available_actions).and_return([:create])
          permission.should_receive(:class).and_return(double(:kind => :test))
          expect { record.may?(:view, target) }.to raise_error(ArgumentError, "action :view not available for permission of kind :test")
        end
      end

    end

    describe '#may_not_access?' do
      it "should invert the result from may_access?" do
        record.should_receive(:may_access?).with(target).and_return(false)
        record.may_not_access?(target).should == true
      end
      it "should invert the result from may_access?" do
        record.should_receive(:may_access?).with(target).and_return(true)
        record.may_not_access?(target).should == false
      end
    end

    describe '#may_not?' do
      it "should invert the result from may?" do
        record.should_receive(:may?).with(:view, target).and_return(false)
        record.may_not?(:view, target).should == true
      end
      it "should invert the result from may?" do
        record.should_receive(:may?).with(:view, target).and_return(true)
        record.may_not?(:view, target).should == false
      end
    end
  end

end