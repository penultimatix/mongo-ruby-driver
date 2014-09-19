require 'spec_helper'

describe Mongo::Server::Description::Inspection::ServerAdded do

  let(:server) do
    Mongo::Server.new('127.0.0.1:27017')
  end

  describe '.run' do

    let(:config) do
      {
        'ismaster' => true,
        'secondary' => false,
        'hosts' => [ '127.0.0.1:27018', '127.0.0.1:27019' ],
        'setName' => 'test'
      }
    end

    let(:description) do
      Mongo::Server::Description.new(server, config)
    end

    let(:updated) do
      Mongo::Server::Description.new(server, new_config)
    end

    let(:listener) do
      double('listener')
    end

    before do
      server.add_listener(Mongo::Event::SERVER_ADDED, listener)
    end

    context 'when a server is added' do

      let(:new_config) do
        { 'hosts' => [ '127.0.0.1:27019', '127.0.0.1:27020' ] }
      end

      it 'fires a server added event' do
        expect(listener).to receive(:handle).with('127.0.0.1:27020')
        described_class.run(description, updated)
      end
    end

    context 'when no server is added' do

      let(:new_config) do
        { 'hosts' => [ '127.0.0.1:27018', '127.0.0.1:27019' ] }
      end

      it 'fires no event' do
        expect(listener).to_not receive(:handle)
        described_class.run(description, updated)
      end
    end
  end
end
