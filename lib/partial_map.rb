#!/usr/bin/env ruby
require 'yaml'

class View
  ROOT = ARGV[1] || File.expand_path(RAILS_ROOT + "/app/views")

  attr_accessor :path, :children, :partial_name

  # Rails app/views dir
  def self.views_dir
    View::ROOT.split("views").first + "views/"
  end

  def initialize(partial_name, parent=nil)
    @partial_name = partial_name.split("/views/").last
    @parent = parent
    if not_found?
      @children = []
    else
      @children = find_partials.map{|p| View.new(p, self)}
    end
  end

  # Directory of the view that called this partial
  def parent_dir
    partial_path = @partial_name.split('/')
    (partial_path.size == 1) ? File.dirname(@parent.path) : self.class.views_dir
  end

  # Path of the partial, minus .html.erb | .erb | ...
  def path_without_extension
    File.join(parent_dir, add_underscore(@partial_name))
  end

  def path
    ['html.erb', 'erb', 'js.erb'].each do |ext|
      path_guess = [path_without_extension, ext].join('.')
      # puts "for #{partial_name}, trying #{path_guess}: #{File.exist?(path_guess).to_s}"
      return path_guess if File.exist?(path_guess)
    end
    return nil
  end

  # Has this view been called by something?
  def is_top_level?
    @parent.nil?
  end

  # Add the underscore to the filename if this is a partial
  def add_underscore(path)
    return path if is_top_level?

    segments = path.split("/")
    segments[segments.size-1] = "_" + segments[segments.size-1]
    segments.join('/')
  end

  def content
    File.read(path)
  end

  # Partial file can't be found?
  def not_found?
    path.nil?
  end

  # Return a hash of this view and its children
  def to_hash
    return "File not found: #{@partial_name} in #{parent_dir}" if not_found?
    return @partial_name if children == []
    {@partial_name => children.map{ |c| c.to_hash } }
  end

  def find_partials
    partials = content.scan(/:partial\s*\=\>\s*[\"\']([^"']*)[\"\']/)
    unless partials.nil?
      partials.map{|partial| partial[0] }
    end
  end
end
