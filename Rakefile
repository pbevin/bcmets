# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

# as per http://www.negativegravity.com/bundler-092-and-rails-235
# to allow CI via integrity
class Pathname  
  def empty?  
    to_s.empty?  
  end  
end  

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
