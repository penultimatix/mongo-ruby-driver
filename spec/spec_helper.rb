if RUBY_VERSION > '1.9' && RUBY_VERSION < '2.2'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    # report groups
    add_group 'Wire Protocol', 'lib/mongo/protocol'
    # filters
    add_filter 'tasks'
    add_filter 'spec'
    add_filter 'bin'
  end
end

require 'mongo'

require 'support/matchers'
require 'support/monitoring'
require 'support/authorization'
require 'support/cluster_simulator'

Mongo::Logger.logger = Logger.new($stdout, Logger::DEBUG)

RSpec.configure do |config|
  config.color     = true
  config.fail_fast = true unless ENV['CI'] || ENV['JENKINS_HOME']
  config.formatter = 'documentation'
  config.include(Authorization)
  config.include(ClusterSimulator::Helpers)
  ClusterSimulator.configure(config)

  config.before(:suite) do
    begin
      # Create the root user administrator as the first user to be added to the
      # database. This user will need to be authenticated in order to add any
      # more users to any other databases.
      p ADMIN_UNAUTHORIZED_CLIENT.database.users.create(ROOT_USER)
    rescue Exception => e
      p e
    end
    begin
      # Adds the test user to the test database with permissions on all
      # databases that will be used in the test suite.
      p ADMIN_AUTHORIZED_CLIENT.database.users.create(TEST_USER)
    rescue Exception => e
      p e
      unless write_command_enabled?
        # If we are on versions less than 2.6, we need to create a user for
        # each database, since the users are not stored in the admin database
        # but in the system.users collection on the datbases themselves. Also,
        # roles in versions lower than 2.6 can only be strings, not hashes.
        begin p ROOT_AUTHORIZED_CLIENT.database.users.create(TEST_READ_WRITE_USER); rescue; end
      end
    end
  end
end

TEST_SET = 'ruby-driver-rs'
COVERAGE_MIN = 90

# For instances where behaviour is different on different versions, we need to
# determin in the specs if we are 2.6 or higher.
#
# @since 2.0.0
def write_command_enabled?
  @client ||= initialize_scanned_client!
  @write_command_enabled ||= @client.cluster.servers.first.write_command_enabled?
end

# Inititializes a basic scanned client to do an ismaster check.
#
# @since 2.0.0
def initialize_scanned_client!
  client = Mongo::Client.new([ '127.0.0.1:27017' ], database: TEST_DB)
  client.cluster.scan!
  client
end

# require all shared examples
Dir['./spec/support/shared/*.rb'].sort.each { |file| require file }
