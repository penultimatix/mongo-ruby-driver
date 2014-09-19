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
  class Cluster
    module Mode

      # Defines behaviour when a cluster is in replica set mode.
      #
      # @since 2.0.0
      class ReplicaSet

        # Select appropriate servers for this mode.
        #
        # @example Select the servers.
        #   ReplicaSet.servers(servers, 'test')
        #
        # @param [ Array<Server> ] servers The known servers.
        # @param [ String ] replica_set_name The name of the replica set.
        #
        # @return [ Array<Server> ] The servers in the replica set.
        #
        # @since 2.0.0
        def self.servers(servers, replica_set_name = nil)
          servers.select do |server|
            (replica_set_name.nil? || server.replica_set_name == replica_set_name) &&
              server.primary? || server.secondary?
          end
        end
      end
    end
  end
end
