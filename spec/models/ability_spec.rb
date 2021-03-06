require 'spec_helper'

describe Ability do

  before :each do
    @user = User.new :user_name => 'test'
  end

  shared_examples "control classes and objects" do |classes, result|
    before :each do
      @ability = Ability.new(@user)
    end

    classes.each do |clazz|
      it "list child" do
        @ability.can?(:index, clazz).should == result
      end
      it "create child" do
        @ability.can?(:create, clazz).should == result
      end
      it "view object" do
        @ability.can?(:read, clazz.new).should == result
      end
      it "edit object" do
        @ability.can?(:update, clazz.new).should == result
      end
    end
  end

  describe '#admin' do
    before :each do
      @user.stub!(:permissions => [Permission::ADMIN[:admin]])
    end

    include_examples "control classes and objects", [Child, ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], true
  end

  describe '#view,search all data and edit' do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:view_and_search], Permission::CHILDREN[:edit]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should have appropriate permissions" do
      ability = Ability.new(@user)
      ability.can?(:index, Child).should be_true
      ability.can?(:create, Child).should be_false
      ability.can?(:read, Child.new).should be_true
      ability.can?(:update, Child.new).should be_true
    end
  end

  describe '#register child' do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:register]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should have appropriate permissions" do
      ability = Ability.new(@user)
      ability.can?(:index, Child).should be_true
      ability.can?(:create, Child).should be_true
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
      ability.can?(:read, Child.new(:created_by => 'test')).should be_true
    end
  end

  describe '#view users' do
    it "it should view object" do
      @user.stub!(:permissions => [Permission::USERS[:view]])
      ability = Ability.new(@user)
      ability.can?(:list, User).should == true
      ability.can?(:read, User.new).should == true
    end

    it "should not view object " do
      @user.stub!(:permissions => [Permission::CHILDREN[:register]])
      ability = Ability.new(@user)
      ability.can?(:list, User).should == false
      ability.can?(:read, User.new).should == false
    end
    it "cannot update user " do
      @user.stub!(:permissions => [Permission::USERS[:view]])
      ability = Ability.new(@user)
      ability.can?(:update, User.new).should == false
      ability.can?(:create, User.new).should == false
    end
  end
  describe '#edit child' do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:edit]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should have appropriate permissions" do
      ability = Ability.new(@user)
      ability.can?(:index, Child).should be_true
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
      ability.can?(:read, Child.new(:created_by => 'test')).should be_true
      ability.can?(:update, Child.new(:created_by => 'test')).should be_true
    end
  end

  describe '#create and edit users' do
    it "should be able to create users" do
      @user.stub!(:permissions => [Permission::USERS[:create_and_edit]])
      ability = Ability.new(@user)
      ability.can?(:create, User.new).should be_true
      ability.can?(:update, User.new).should be_true
      ability.can?(:destroy, User.new).should be_false
    end
    it "should be able to view users" do
      @user.stub!(:permissions => [Permission::USERS[:create_and_edit]])
      ability = Ability.new(@user)
      ability.can?(:read, User.new).should be_true
    end
  end

  describe "destroy users" do
    it "should be able to delete users" do
      @user.stub!(:permissions => [Permission::USERS[:destroy]])
      ability = Ability.new(@user)
      ability.can?(:destroy, User.new).should be_true
      ability.can?(:read, User.new).should be_true
      ability.can?(:edit, User.new).should be_false
    end
  end

  describe "disable users" do
    it "should be able to disable users" do
      @user.stub!(:permissions => [Permission::USERS[:disable]])
      ability = Ability.new(@user)
      ability.can?(:create, User.new).should be_false
      ability.can?(:update, User.new).should be_true
      ability.can?(:read, User.new).should be_true
    end
  end

  describe "export children to photowall" do
    before :each do
      @user.stub!(:permissions => [Permission::CHILDREN[:export]])
    end

    include_examples "control classes and objects", [ContactInformation, Device, FormSection, Session, SuggestedField, User, Role], false

    it "should be able to export children" do
      ability = Ability.new(@user)
      ability.can?(:export, Child).should be_true
      ability.can?(:index, Child).should be_false
      ability.can?(:read, Child.new).should be_false
      ability.can?(:update, Child.new).should be_false
    end
  end

  describe "view and search child records" do
    it "should be able to view and search any child record" do
      @user.stub!(:permissions => [ Permission::CHILDREN[:view_and_search]])
      @ability = Ability.new(@user)
      @ability.can?(:index, Child.new).should == true
      @ability.can?(:read, Child.new).should == true
      @ability.can?(:view_all, Child).should == true
    end
  end

  describe "blacklist" do

    before :each do
      @user.stub!(:permissions => [Permission::DEVICES[:black_list]])
    end

    include_examples "control classes and objects", [Child, ContactInformation, FormSection, Session, SuggestedField, User, Role], false

    it "should blacklist a device for users with relevant permission alone" do
      ability = Ability.new(@user)
      ability.can?(:update, Device).should be_true
      ability.can?(:index, Device).should be_true
      ability.can?(:read, User.new).should be_false
    end
  end
end
