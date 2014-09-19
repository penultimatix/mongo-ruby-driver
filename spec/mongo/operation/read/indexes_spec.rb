require 'spec_helper'

describe Mongo::Operation::Read::Indexes do

  describe '#execute' do

    let(:spec) do
      { name: 1 }
    end

    before do
      authorized_collection.indexes.ensure(spec, unique: true)
    end

    after do
      authorized_collection.indexes.drop(spec)
    end

    let(:operation) do
      described_class.new(db_name: TEST_DB, coll_name: TEST_COLL)
    end

    let(:indexes) do
      operation.execute(authorized_primary.context)
    end

    it 'returns the indexes for the collection' do
      expect(indexes.documents.size).to eq(2)
    end
  end
end
