# Created by elliottcable (elliottcable.name)
# Part of the ystyle SASS/CSS pack (find.yreality.net/ystyle)
# Licensed as Creative Commons BY-NC-SA 3.0
# -  (creativecommons.org/licenses/by-nc-sa/3.0)
# -------------------------------------
# Rakefile to generate CSS from the SASS

require 'sass/engine'

task :default => [:sass]
task :sass => [:update, :compile]

desc 'Update SASS code from Git'
task :update do
  puts 'Updating SASS...'
  if system 'git pull'
    puts 'SASS updated!'
  else
    puts 'SASS update failed'
    exit
  end
end

desc 'Clear compiled CSS files'
task :clobber do
  puts 'Clearing CSS...'
  Dir['./compiled/**.css'].each do |file|
    File.delete file
    print "#{File.basename(file)} deleted, "
  end
  puts 'All CSS cleared!'
end

desc 'Compile SASS templates to CSS'
task :compile => [:clobber] do
  puts 'Compiling SASS...'
  Dir['./*.sass'].each do |sass_filename|
    File.open(sass_filename, 'r') do |sass_file|
      content = sass_file.read
      
      css_filename = sass_filename.gsub('.sass','.css').gsub('./','./compiled/')
      File.open(css_filename,'w') do |css_file|
        css_file << Sass::Engine.new(content, :style => :compressed, :filename => sass_filename.to_s, :load_paths => ['.']).to_css
      end
      
      xcss_filename = sass_filename.gsub('.sass','.x.css').gsub('./','./compiled/')
      File.open(xcss_filename,'w') do |xcss_file|
        xcss_file << Sass::Engine.new(content, :style => :nested, :filename => sass_filename.to_s, :load_paths => ['.']).to_css
      end
      
      puts " - #{File.basename(sass_filename)} compiled to #{File.basename(css_filename)} & #{File.basename(xcss_filename)}"
    end
  end
  puts 'SASS compiled!'
end

desc 'Test SASS files for problems'
task :test do
  Dir['./includes/*.sass'].each do |sass_filename|
    File.open(sass_filename, 'r') do |sass_file|
      begin
        Sass::Engine.new(sass_file.read, :style => :nested, :filename => sass_filename.to_s, :load_paths => ['.']).to_css
      rescue Exception => e
        puts "#{sass_filename} raised #{e.inspect}"
      end
    end
  end
end