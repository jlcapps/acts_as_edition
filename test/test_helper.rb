$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
RAILS_ROOT = File.dirname(__FILE__)

require 'active_record'
require 'active_record/fixtures'
require 'active_support'
require 'active_support/test_case'
require 'rubygems'
require 'test/unit'

require "#{File.dirname(__FILE__)}/../init"

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.configurations = { "test" => config[ENV['DB'] || 'sqlite3'] }
ActiveRecord::Base.establish_connection(
  ActiveRecord::Base.configurations['test']
)
 
load(File.dirname(__FILE__) + "/schema.rb")
 
class ActiveSupport::TestCase #:nodoc:
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
  $LOAD_PATH.unshift(self.fixture_path)
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(self.fixture_path, 
        table_names
      ) { yield }
    else
      Fixtures.create_fixtures(self.fixture_path, table_names)
    end
  end
 
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
end
