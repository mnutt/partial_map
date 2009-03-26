require 'partial_map'

desc "Print a heirarchy of views and the partials they call.  Optionally takes a view directory as an argument."
task :partial_map do
  view_paths = Dir.glob(View::ROOT+"/**/*.erb")
  views = view_paths.map {|v|
    next if v =~ /\/\_/ or v.nil?
 
    v ||= ''
    v.gsub!(/\.html|\.js|\.erb|\.builder|\.xml/, '')
    View.new(v)
  }.compact

  puts views.map{|v| v.to_hash}.to_yaml
end
