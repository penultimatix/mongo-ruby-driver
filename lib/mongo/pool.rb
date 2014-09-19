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

require 'mongo/pool/queue'

module Mongo

  class SocketError < StandardError; end
  class SocketTimeoutError < SocketError; end
  class ConnectionError < StandardError; end

  class Pool

    # Used for synchronization of pools access.
    MUTEX = Mutex.new

    # The default max size for the connection pool.
    POOL_SIZE = 5

    # The default timeout for getting connections from the queue.
    TIMEOUT = 0.5

    # @return [ Hash ] options The pool options.
    attr_reader :options

    # Check a connection back into the pool. Will pull the connection from a
    # thread local stack that should contain it after it was checked out.
    #
    # @example Checkin the thread's connection to the pool.
    #   pool.checkin
    #
    # @since 2.0.0
    def checkin(connection)
      queue.enqueue(connection)
    end

    # Check a connection out from the pool. If a connection exists on the same
    # thread it will get that connection, otherwise it will dequeue a
    # connection from the queue and pin it to this thread.
    #
    # @example Check a connection out from the pool.
    #   pool.checkout
    #
    # @return [ Mongo::Pool::Connection ] The checked out connection.
    #
    # @since 2.0.0
    def checkout
      queue.dequeue(timeout)
    end

    # Create the new connection pool.
    #
    # @example Create the new connection pool.
    #   Pool.new(timeout: 0.5) do
    #     Connection.new
    #   end
    #
    # @note A block must be passed to set up the connections on initialization.
    #
    # @param [ Hash ] options The connection pool options.
    #
    # @since 2.0.0
    def initialize(options = {}, &block)
      @options = options.freeze
      @queue = Queue.new(pool_size, &block)
    end

    # Get the default size of the connection pool.
    #
    # @example Get the pool size.
    #   pool.pool_size
    #
    # @return [ Integer ] The size of the pool.
    #
    # @since 2.0.0
    def pool_size
      @pool_size ||= options[:pool_size] || POOL_SIZE
    end

    # Get the timeout for checking connections out from the pool.
    #
    # @example Get the pool timeout.
    #   pool.timeout
    #
    # @return [ Float ] The pool timeout.
    #
    # @since 2.0.0
    def timeout
      @timeout ||= options[:connect_timeout] || TIMEOUT
    end

    # Yield the block to a connection, while handling checkin/checkout logic.
    #
    # @example Execute with a connection.
    #   pool.with_connection do |connection|
    #     connection.read
    #   end
    #
    # @return [ Object ] The result of the block.
    #
    # @since 2.0.0
    def with_connection
      begin
        connection = checkout
        yield(connection)
      ensure
        checkin(connection)
      end
    end

    private

    attr_reader :queue

    class << self

      # Get a connection pool for the provided server.
      #
      # @example Get a connection pool.
      #   Mongo::Pool.get(server)
      #
      # @param [ Mongo::Server ] server The server.
      #
      # @return [ Mongo::Pool ] The connection pool.
      #
      # @since 2.0.0
      def get(server)
        MUTEX.synchronize do
          pools[server.address] ||= create_pool(server)
        end
      end

      private

      def create_pool(server)
        Pool.new(
          pool_size: server.options[:pool_size],
          timeout: server.options[:connect_timeout]
        ) do
          Connection.new(server, server.options)
        end
      end

      def pools
        @pools ||= {}
      end
    end
  end
end
