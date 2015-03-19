# Copyright (C) 2014-2015 MongoDB, Inc.
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
  class Address

    # Sets up resolution with IPv6 support if the address is an ip
    # address.
    #
    # @since 2.0.0
    class IPv6

      # @return [ String ] host The original host name.
      attr_reader :host

      # @return [ Integer ] port The port.
      attr_reader :port

      # @return [ String ] seed The seed address.
      attr_reader :seed

      # The regular expression to use to match an IPv6 ip address.
      #
      # @since 2.0.0
      MATCH = Regexp.new('::').freeze

      # Initialize the IPv6 resolver.
      #
      # @example Initialize the resolver.
      #   IPv6.new("[::1]:28011")
      #
      # @param [ String ] address The address to resolve.
      #
      # @since 2.0.0
      def initialize(address)
        parts = address.match(/\[(.+)\]:?(.+)?/)
        @host = parts[1]
        @port = (parts[2] || 27017).to_i
        @seed = address
      end

      # Get a socket for the provided address type, given the options.
      #
      # @example Get an IPv6 socket.
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
          Socket::SSL.new(host, port, timeout, Socket::PF_INET6, ssl_options)
        else
          Socket::TCP.new(host, port, timeout, Socket::PF_INET6)
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
