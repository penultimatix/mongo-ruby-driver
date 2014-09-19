# Copyright (C) 2009-2014 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mongo
  class Server
    class Address

      # Sets up DNS resolution with IPv4 support if the address is an ip
      # address.
      #
      # @since 2.0.0
      class IPv4
        include Resolvable

        # The regular expression to use to match an IPv4 ip address.
        #
        # @since 2.0.0
        MATCH = Regexp.new('/\./').freeze

        # Initialize the IPv4 resolver.
        #
        # @example Initialize the resolver.
        #   IPv4.new("127.0.0.1:28011")
        #
        # @param [ String ] address The address to resolve.
        #
        # @since 2.0.0
        def initialize(address)
          parts = address.split(':')
          @host = parts[0]
          @port = (parts[1] || 27017).to_i
          @seed = address
          resolve!
        end

        # Get the pattern to use when the DNS is resolved to match an IPv4
        # address.
        #
        # @example Get the IPv4 regex pattern.
        #   ipv4.pattern
        #
        # @return [ Regexp ] The regexp.
        #
        # @since 2.0.0
        def pattern
          Resolv::IPv4::Regex
        end

        # Get a socket for the provided address type, given the options.
        #
        # @example Get an IPv4 socket.
        #   ipv4.socket(5, :ssl => true)
        #
        # @param [ Float ] timeout The socket timeout.
        # @param [ Hash ] ssl_options SSL options.
        #
        # @return [ Pool::Socket::SSL, Pool::Socket::TCP ] The socket.
        #
        # @since 2.0.0
        def socket(timeout, ssl_options = {})
          unless ssl_options.empty?
            Socket::SSL.new(ip, port, timeout, Socket::PF_INET, ssl_options)
          else
            Socket::TCP.new(ip, port, timeout, Socket::PF_INET)
          end
        end

        # Get the address as a string.
        #
        # @example Get the address as a string.
        #   ipv4.to_s
        #
        # @return [ String ] The nice string.
        #
        # @since 2.0.0
        def to_s
          "#{host}:#{port}"
        end
      end
    end
  end
end
