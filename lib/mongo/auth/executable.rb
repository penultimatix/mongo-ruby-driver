# Copyright (C) 2009 - 2014 MongoDB Inc.
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
  module Auth

    # Defines common behaviour for executable authorization commands.
    #
    # @since 2.0.0
    module Executable

      # @return [ Mongo::Auth::User ] The user to authenticate.
      attr_reader :user

      # Instantiate a new authenticator.
      #
      # @example Create the authenticator.
      #   Mongo::Auth::X509.new(user)
      #
      # @param [ Mongo::Auth::User ] user The user to authenticate.
      #
      # @since 2.0.0
      def initialize(user)
        @user = user
      end

      private

      # If we are on MongoDB 2.6 and higher, we *always* authorize against the
      # admin database. Otherwise for 2.4 and lower we authorize against the
      # database provided, or the optional auth_source option. The logic for
      # that is encapsulated in the User class.
      def auth_database(connection)
        if connection.write_command_enabled?
          Database::ADMIN
        else
          user.database
        end
      end
    end
  end
end
