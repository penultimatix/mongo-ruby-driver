require 'spec_helper'

describe Mongo::Operation::Write::BulkInsert do
  include_context 'operation'

  let(:documents) do
    [{ :name => 'test' }]
  end

  let(:spec) do
    { documents: documents,
      db_name: db_name,
      coll_name: coll_name,
      write_concern: write_concern
    }
  end

  let(:op) do
    described_class.new(spec)
  end

  describe '#initialize' do

    context 'spec' do

      it 'sets the spec' do
        expect(op.spec).to eq(spec)
      end
    end
  end

  describe '#==' do

    context 'spec' do

      context 'when two inserts have the same specs' do

        let(:other) do
          described_class.new(spec)
        end

        it 'returns true' do
          expect(op).to eq(other)
        end
      end

      context 'when two inserts have different specs' do

        let(:other_docs) do
          [{ :bar => 1 }]
        end

        let(:other_spec) do
          { :documents     => other_docs,
            :db_name       => 'test',
            :coll_name     => 'coll_name',
            :write_concern => { 'w' => 1 },
            :ordered       => true
          }
        end

        let(:other) do
          described_class.new(other_spec)
        end

        it 'returns false' do
          expect(op).not_to eq(other)
        end
      end
    end
  end

  describe '#dup' do

    context 'deep copy' do

      it 'copies the list of documents' do
        copy = op.dup
        expect(copy.spec[:documents]).to_not be(op.spec[:documents])
      end
    end
  end

  describe '#execute' do

    before do
      authorized_collection.indexes.create_one({ name: 1 }, { unique: true })
    end

    after do
      authorized_collection.find.delete_many
      authorized_collection.indexes.drop_one('name_1')
    end

    context 'when inserting a single document' do

      context 'when the insert succeeds' do

        let(:response) do
          op.execute(authorized_primary.context)
        end

        it 'inserts the documents into the database', if: write_command_enabled? do
          expect(response.written_count).to eq(1)
        end

        it 'inserts the documents into the database', unless: write_command_enabled? do
          expect(response.written_count).to eq(0)
        end
      end
    end

    context 'when inserting multiple documents' do

      context 'when the insert succeeds' do

        let(:documents) do
          [{ name: 'test1' }, { name: 'test2' }]
        end

        let(:response) do
          op.execute(authorized_primary.context)
        end

        it 'inserts the documents into the database', if: write_command_enabled? do
          expect(response.written_count).to eq(2)
        end

        it 'inserts the documents into the database', unless: write_command_enabled? do
          expect(response.written_count).to eq(0)
        end
      end
    end

    context 'when the inserts are ordered' do

      let(:documents) do
        [{ name: 'test' }, { name: 'test' }, { name: 'test1' }]
      end

      let(:spec) do
        { documents: documents,
          db_name: db_name,
          coll_name: coll_name,
          write_concern: write_concern,
          ordered: true
        }
      end

      let(:failing_insert) do
        described_class.new(spec)
      end

      context 'when write concern is acknowledged' do

        let(:write_concern) do
          Mongo::WriteConcern.get(w: 1)
        end

        context 'when the insert fails' do
    
          it 'aborts after first error' do
            failing_insert.execute(authorized_primary.context)
            expect(authorized_collection.find.count).to eq(1)
          end
        end
      end

      context 'when write concern is unacknowledged' do

        let(:write_concern) do
          Mongo::WriteConcern.get(w: 0)
        end

        context 'when the insert fails' do

          it 'aborts after first error' do
            failing_insert.execute(authorized_primary.context)
            expect(authorized_collection.find.count).to eq(1)
          end
        end
      end
    end

    context 'when the inserts are unordered' do

      let(:documents) do
        [{ name: 'test' }, { name: 'test' }, { name: 'test1' }]
      end

      let(:spec) do
        { documents: documents,
          db_name: db_name,
          coll_name: coll_name,
          write_concern: write_concern,
          ordered: false
        }
      end

      let(:failing_insert) do
        described_class.new(spec)
      end

      context 'when write concern is acknowledged' do

        let(:write_concern) do
          Mongo::WriteConcern.get(w: 1)
        end

        context 'when the insert fails' do
    
          it 'does not abort after first error' do
            failing_insert.execute(authorized_primary.context)
            expect(authorized_collection.find.count).to eq(2)
          end
        end
      end

      context 'when write concern is unacknowledged' do

        let(:write_concern) do
          Mongo::WriteConcern.get(w: 0)
        end

        context 'when the insert fails' do

          it 'does not after first error' do
            failing_insert.execute(authorized_primary.context)
            expect(authorized_collection.find.count).to eq(2)
          end
        end
      end
    end
  end
end
