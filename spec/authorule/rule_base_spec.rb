require 'spec_helper'

describe Authorule::RuleBase do

  let(:permission) { double() }
  let(:rule_base) { Authorule::RuleBase.new(rules) }

  context "providing no rules" do
    let(:rules) { [] }

    it "should deny all access" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :custom, :name => 'something', :action => nil)
      ])
      rule_base.run(permission).should == false
    end
  end

  context "providing an 'allow all' rule" do
    let(:rules) { [ double(:key => 'all', :allow? => true) ] }

    it "should allow all access" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :custom, :name => 'something', :action => nil)
      ])
      rule_base.run(permission).should == true
    end
  end

  context "providing a cascading rule set" do
    let(:rules) do
      [
        double(:key => 'all', :allow? => false),   # Deny all
        double(:key => 'resource:all', :allow? => true),   # Allow all resources
        double(:key => 'resource:account', :allow? => false),   # Deny access to resource 'account'
      ]
    end

    it "should deny access to a non-resource permission" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :custom, :name => 'something', :action => nil)
      ])
      rule_base.run(permission).should == false
    end

    it "should allow access to a non-account resource permission" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :resource, :name => 'contact', :action => nil)
      ])
      rule_base.run(permission).should == true
    end

    it "should deny access to an account resource permission" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :resource, :name => 'account', :action => nil)
      ])
      rule_base.run(permission).should == false
    end
  end

  context "using a permission with dependencies" do

    let(:permission) do
      # Create a permission that requires both access to space:crm as well as resource:account.
      double(:with_dependencies => [
        double(:kind => :space, :name => 'crm', :action => nil),
        double(:kind => :resource, :name => 'account', :action => nil)
      ])
    end

    # deny CRM, allow account
    let(:crm_rule) { double(:key => 'space:crm', :allow? => false) }
    let(:account_rule) { double(:key => 'space:crm', :allow? => true) }

    it "should allow access if the account rule is defined last" do
      rule_base = Authorule::RuleBase.new([ crm_rule, account_rule ])
      rule_base.run(permission).should == true
    end

    it "should deny access if the CRM rule is defined last" do
      rule_base = Authorule::RuleBase.new([ account_rule, crm_rule ])
      rule_base.run(permission).should == false
    end

  end

  context "targeting specific actions" do

    let(:rules) do
      [
        double(:key => 'resource:all', :allow? => true),   # Allow all resources
        double(:key => 'resource:all:create', :allow? => false),   # Deny creating all resources
        double(:key => 'resource:account:create', :allow? => true),   # Deny creating resource 'account'
      ]
    end

    it "should allow viewing a 'contact' resource" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :resource, :name => 'contact', :action => :view)
      ])
      rule_base.run(permission).should == true
    end

    it "should allow viewing an 'account' resource" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :resource, :name => 'account', :action => :view)
      ])
      rule_base.run(permission).should == true
    end

    it "should deny creating a 'contact' resource" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :resource, :name => 'contact', :action => :create)
      ])
      rule_base.run(permission).should == false
    end

    it "should allow creating an 'account' resource" do
      permission.should_receive(:with_dependencies).and_return([
        double(:kind => :resource, :name => 'account', :action => :create)
      ])
      rule_base.run(permission).should == true
    end

  end

end