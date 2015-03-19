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

require 'mongo/address/ipv4'
require 'mongo/address/ipv6'
require 'mongo/address/unix'

module Mongo

  # Represents an address to a server, either with an IP address or socket
  # path.
  #
  # @since 2.0.0
  class Address
    extend Forwardable

    # Delegate the ip, host, and port methods to the resolver.
    #
    # @since 2.0.0
    def_delegators :@resolver, :host, :port, :socket, :seed, :to_s

    # @return [ Integer ] port The port to the connect to.
    attr_reader :resolver

    # Check equality of the address to another.
    #
    # @example Check address equality.
    #   address == other
    #
    # @param [ Object ] other The other object.
    #
    # @return [ true, false ] If the objects are equal.
    #
    # @since 2.0.0
    def ==(other)
      return false unless other.is_a?(Address)
      host == other.host && port == other.port
    end

    # Calculate the hash value for the address.
    #
    # @example Calculate the hash value.
    #   address.hash
    #
    # @return [ Integer ] The hash value.
    #
    # @since 2.0.0
    def hash
      [ host, port ].hash
    end

    # Initialize the address.
    #
    # @example Initialize the address with a DNS entry and port.
    #   Mongo::Address.new("app.example.com:27017")
    #
    # @example Initialize the address with a DNS entry and no port.
    #   Mongo::Address.new("app.example.com")
    #
    # @example Initialize the address with an IPV4 address and port.
    #   Mongo::Address.new("127.0.0.1:27017")
    #
    # @example Initialize the address with an IPV4 address and no port.
    #   Mongo::Address.new("127.0.0.1")
    #
    # @example Initialize the address with an IPV6 address and port.
    #   Mongo::Address.new("[::1]:27017")
    #
    # @example Initialize the address with an IPV6 address and no port.
    #   Mongo::Address.new("[::1]")
    #
    # @example Initialize the address with a unix socket.
    #   Mongo::Address.new("/path/to/socket.sock")
    #
    # @param [ String ] seed The provided address.
    # @param [ Hash ] options The address options.
    #
    # @since 2.0.0
    def initialize(seed, options = {})
      address = seed.downcase
      case address
        when Unix::MATCH then @resolver = Unix.new(address)
        when IPv6::MATCH then @resolver = IPv6.new(address)
        else @resolver = IPv4.new(address)
      end
    end

    # Get a pretty printed address inspection.
    #
    # @example Get the address inspection.
    #   address.inspect
    #
    # @return [ String ] The nice inspection string.
    #
    # @since 2.0.0
    def inspect
      "#<Mongo::Address:0x#{object_id} address=#{resolver.to_s}>"
    end
  end
end
