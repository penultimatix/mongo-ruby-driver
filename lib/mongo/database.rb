# Copyright (C) 2009-2014 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mongo

  # Represents a database on the db server and operations that can execute on
  # it at this level.
  #
  # @since 2.0.0
  class Database
    extend Forwardable

    # The admin database name.
    #
    # @since 2.0.0
    ADMIN = 'admin'.freeze

    # The "collection" that database commands operate against.
    #
    # @since 2.0.0
    COMMAND = '$cmd'.freeze

    # The name of the collection that holds all the collection names.
    #
    # @since 2.0.0
    NAMESPACES = 'system.namespaces'.freeze

    # @return [ Mongo::Client ] The database client.
    attr_reader :client

    # @return [ String ] The name of the collection.
    attr_reader :name

    # Get cluser and server preference from client.
    def_delegators :@client, :cluster, :server_preference, :write_concern

    # Check equality of the database object against another. Will simply check
    # if the names are the same.
    #
    # @example Check database equality.
    #   database == other
    #
    # @param [ Object ] other The object to check against.
    #
    # @return [ true, false ] If the objects are equal.
    #
    # @since 2.0.0
    def ==(other)
      return false unless other.is_a?(Database)
      name == other.name
    end

    # Get a collection in this database by the provided name.
    #
    # @example Get a collection.
    #   database[:users]
    #
    # @param [ String, Symbol ] collection_name The name of the collection.
    # @param [ Hash ] options The options to the collection.
    #
    # @return [ Mongo::Collection ] The collection object.
    #
    # @since 2.0.0
    def [](collection_name, options = {})
      Collection.new(self, collection_name, options)
    end
    alias_method :collection, :[]

    # Get all the names of the non system collections in the database.
    #
    # @example Get the collection names.
    #   database.collection_names
    #
    # @return [ Array<String> ] The names of all non-system collections.
    #
    # @since 2.0.0
    def collection_names
      namespaces = collection(NAMESPACES).find(
        :name => { '$not' => /system\.|\$/ }
      )
      namespaces.map do |document|
        collection = document['name']
        collection[name.length + 1, collection.length]
      end
    end

    # Get all the collections that belong to this database.
    #
    # @example Get all the collections.
    #   database.collections
    #
    # @return [ Array<Mongo::Collection> ] All the collections.
    #
    # @since 2.0.0
    def collections
      collection_names.map { |name| collection(name) }
    end

    # Execute a command on the database.
    #
    # @example Execute a command.
    #   database.command(:ismaster => 1)
    #
    # @param [ Hash ] operation The command to execute.
    #
    # @return [ Hash ] The result of the command execution.
    def command(operation)
      server = client.server_preference.select_servers(cluster.servers).first
      Operation::Command.new({
        :selector => operation,
        :db_name => name,
        :options => { :limit => -1 }
      }).execute(server.context)
    end

    # Drop the database and all its associated information.
    #
    # @example Drop the database.
    #   database.drop
    #
    # @return [ Result ] The result of the command.
    #
    # @since 2.0.0
    def drop
      command(:dropDatabase => 1)
    end

    # Instantiate a new database object.
    #
    # @example Instantiate the database.
    #   Mongo::Database.new(client, :test)
    #
    # @param [ Mongo::Client ] client The driver client.
    # @param [ String, Symbol ] name The name of the database.
    #
    # @raise [ Mongo::Database::InvalidName ] If the name is nil.
    #
    # @since 2.0.0
    def initialize(client, name)
      raise InvalidName.new unless name
      @client = client
      @name = name.to_s.freeze
    end

    # Get the user view for this database.
    #
    # @example Get the user view.
    #   database.users
    #
    # @return [ View::User ] The user view.
    #
    # @since 2.0.0
    def users
      Auth::User::View.new(self)
    end

    # Exception that is raised when trying to create a database with no name.
    #
    # @since 2.0.0
    class InvalidName < DriverError

      # The message is constant.
      #
      # @since 2.0.0
      MESSAGE = 'nil is an invalid database name. ' +
        'Please provide a string or symbol.'

      # Instantiate the new exception.
      #
      # @example Instantiate the exception.
      #   Mongo::Database::InvalidName.new
      #
      # @since 2.0.0
      def initialize
        super(MESSAGE)
      end
    end
  end
end
