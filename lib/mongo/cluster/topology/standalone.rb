# Copyright (C) 2014-2015 MongoDB, Inc.
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
  class Cluster
    module Topology

      # Defines behaviour for when a cluster is in standalone topology.
      #
      # @since 2.0.0
      class Standalone

        # The display name for the topology.
        #
        # @since 2.0.0
        NAME = 'Standalone'.freeze

        # Get the display name.
        #
        # @example Get the display name.
        #   Standalone.display_name
        #
        # @return [ String ] The display name.
        #
        # @since 2.0.0
        def display_name
          NAME
        end

        # Elect a primary server within this topology.
        #
        # @example Elect a primary server.
        #   topology.elect_primary(description, servers)
        #
        # @param [ Server::Description ] description The description of the
        #   elected primary.
        # @param [ Array<Server> ] servers The list of known servers to the
        #   cluster.
        #
        # @return [ Standalone ] The topology.
        def elect_primary(description, servers); self; end

        # Initialize the topology with the options.
        #
        # @example Initialize the topology.
        #   Standalone.new(options)
        #
        # @param [ Hash ] options The options.
        #
        # @since 2.0.0
        def initialize(options)
          @options = options
        end

        # A standalone topology is not a replica set.
        #
        # @example Is the topology a replica set?
        #   Sharded.replica_set?
        #
        # @return [ false ] Always false.
        #
        # @since 2.0.0
        def replica_set?; false; end

        # Standalone topologies have no replica set name.
        #
        # @example Get the replica set name.
        #   standalone.replica_set_name
        #
        # @return [ nil ] Always nil.
        #
        # @since 2.0.0
        def replica_set_name; nil; end

        # Select appropriate servers for this topology.
        #
        # @example Select the servers.
        #   Standalone.servers(servers, 'test')
        #
        # @param [ Array<Server> ] servers The known servers.
        #
        # @return [ Array<Server> ] The standalone servers.
        #
        # @since 2.0.0
        def servers(servers, name = nil)
          [ servers.detect{ |server| server.standalone? } ]
        end

        # A standalone topology is not sharded.
        #
        # @example Is the topology sharded?
        #   Standalone.sharded?
        #
        # @return [ false ] Always false.
        #
        # @since 2.0.0
        def sharded?; false; end

        # A standalone topology is standalone.
        #
        # @example Is the topology standalone?
        #   Standalone.standalone?
        #
        # @return [ true ] Always true.
        #
        # @since 2.0.0
        def standalone?; true; end

        # An standalone topology is not unknown.
        #
        # @example Is the topology unknown?
        #   Standalone.unknown?
        #
        # @return [ false ] Always false.
        #
        # @since 2.0.0
        def unknown?; false; end
      end
    end
  end
end
