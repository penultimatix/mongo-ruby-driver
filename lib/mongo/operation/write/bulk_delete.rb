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
  module Operation
    module Write

      # A MongoDB bulk delete operation.
      #
      # @note If a server with version >= 2.5.5 is selected, a write command
      #   operation will be created and sent instead.
      #
      # @example Create the delete operation.
      #   Write::BulkDelete.new({
      #     :deletes => [{ :q => { :foo => 1 }, :limit => 1 }],
      #     :db_name => 'test',
      #     :coll_name => 'test_coll',
      #     :write_concern => write_concern
      #   })
      #
      # @param [ Hash ] spec The specifications for the delete.
      #
      # @option spec :deletes [ Array ] The delete documents.
      # @option spec :db_name [ String ] The name of the database on which
      #   the delete should be executed.
      # @option spec :coll_name [ String ] The name of the collection on which
      #   the delete should be executed.
      # @option spec :write_concern [ Mongo::WriteConcern::Mode ] The write concern
      #   for this operation.
      # @option spec :ordered [ true, false ] Whether the operations should be
      #   executed in order.
      # @option spec :options [Hash] Options for the command, if it ends up being a
      #   write command.
      #
      # @since 2.0.0
      class BulkDelete
        include Executable
        include Specifiable

        # Execute the delete operation.
        #
        # @example Execute the operation.
        #   operation.execute(context)
        #
        # @params [ Mongo::Server::Context ] The context for this operation.
        #
        # @return [ Result ] The result.
        #
        # @since 2.0.0
        def execute(context)
          if context.write_command_enabled?
            execute_write_command(context)
          else
            execute_message(context)
          end
        end

        private

        def execute_write_command(context)
          Result.new(Command::Delete.new(spec).execute(context)).validate!
        end

        def execute_message(context)
          replies = messages(context).map do |m|
            context.with_connection do |connection|
              result = Result.new(connection.dispatch([ m, gle ]))
              result.validate! if ordered?
              result.reply
            end
          end
          Result.new(replies).validate!
        end

        # @todo put this somewhere else
        def ordered?
          @spec.fetch(:ordered, true)
        end

        def gle
          gle_message = ( ordered? && write_concern.get_last_error.nil? ) ?
                           Mongo::WriteConcern::Mode.get(:w => 1).get_last_error :
                           write_concern.get_last_error
          if gle_message
            Protocol::Query.new(
              db_name,
              Database::COMMAND,
              gle_message,
              options.merge(limit: -1)
            )
          end
        end

        def initialize_copy(original)
          @spec = original.spec.dup
          @spec[:deletes] = original.spec[:deletes].clone
        end

        def messages(context)
          # @todo: break up into multiple messages depending on max_message_size
          deletes.collect do |del|
            opts = ( del[:limit] || 0 ) <= 0 ? {} : { :flags => [ :single_remove ] }
            Protocol::Delete.new(db_name, coll_name, del[:q], opts)
          end
        end
      end
    end
  end
end
