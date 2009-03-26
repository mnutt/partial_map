$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', "rails_app"))

require 'rubygems'
require 'spec'
require 'partial_map/view'

describe 'PartialMap::View' do
  it 'should have a default root directory that is the rails view dir' do
    PartialMap::View::ROOT.should == File.expand_path(File.dirname(__FILE__) + "/../rails_app/app/views")
  end

  describe 'with no partials' do
    before do
      @view = PartialMap::View.new("users/new")
    end

    it 'should get the correct path of a view' do
      @view.path.should == RAILS_ROOT + "/app/views/users/new.html.erb"
    end

    it 'should not have any children' do
      @view.children.should be_empty
    end
  end

  describe 'with a single partial' do
    it 'should have a single child' do
      @view = PartialMap::View.new("users/index")
      @view.children.size.should == 1
    end
  end

  describe 'with a partial that has a different directory' do
    before do
      @view = PartialMap::View.new("posts/post")
      @partial = @view.children.first
    end

    it 'should have the correct partial_name' do
      @partial.partial_name.should == "users/user"
    end

    it 'should have the correct path' do
      @partial.path.should == RAILS_ROOT + "/app/views/users/_user.html.erb"
    end
  end

  describe 'a nonexistent view' do
    before do
     @view = PartialMap::View.new("users/notfound")
    end

    it 'should be not_found' do
      @view.should be_not_found
    end

    it 'should not have any children' do
      @view.children.should be_empty
    end

    it 'should print a not found message' do
      @view.to_hash.should =~ /File not found/
    end
  end
end
