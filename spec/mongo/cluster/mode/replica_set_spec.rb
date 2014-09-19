require 'spec_helper'

describe Mongo::Cluster::Mode::ReplicaSet do

  describe '.servers' do

    let(:mongos) do
      Mongo::Server.new('127.0.0.1:27017')
    end

    let(:standalone) do
      Mongo::Server.new('127.0.0.1:27017')
    end

    let(:replica_set) do
      Mongo::Server.new('127.0.0.1:27017')
    end

    let(:replica_set_two) do
      Mongo::Server.new('127.0.0.1:27017')
    end

    let(:mongos_description) do
      Mongo::Server::Description.new(mongos, { 'msg' => 'isdbgrid' })
    end

    let(:standalone_description) do
      Mongo::Server::Description.new(standalone, { 'ismaster' => true })
    end

    let(:replica_set_description) do
      Mongo::Server::Description.new(replica_set, { 'ismaster' => true, 'setName' => 'testing' })
    end

    let(:replica_set_two_description) do
      Mongo::Server::Description.new(replica_set, { 'ismaster' => true, 'setName' => 'test' })
    end

    before do
      mongos.instance_variable_set(:@description, mongos_description)
      standalone.instance_variable_set(:@description, standalone_description)
      replica_set.instance_variable_set(:@description, replica_set_description)
      replica_set_two.instance_variable_set(:@description, replica_set_two_description)
    end

    context 'when no replica set name is provided' do

      let(:servers) do
        described_class.servers([ mongos, standalone, replica_set, replica_set_two ])
      end

      it 'returns only replica set members' do
        expect(servers).to eq([ replica_set, replica_set_two ])
      end
    end

    context 'when a replica set name is provided' do

      let(:servers) do
        described_class.servers([ mongos, standalone, replica_set, replica_set_two ], 'testing')
      end

      it 'returns only replica set members is the provided set' do
        expect(servers).to eq([ replica_set ])
      end
    end
  end
end
