require 'spec_helper'

describe Mongo::Server::Monitor do

  let(:address) do
    Mongo::Address.new(DEFAULT_ADDRESS)
  end

  let(:listeners) do
    Mongo::Event::Listeners.new
  end

  describe '#scan!' do

    context 'when the ismaster command succeeds' do

      let(:monitor) do
        described_class.new(address, listeners)
      end

      before do
        monitor.scan!
      end

      it 'updates the server description', if: standalone? do
        expect(monitor.description).to be_standalone
      end

      it 'updates the server description', if: replica_set? do
        expect(monitor.description).to be_primary
      end

      it 'updates the server description', if: sharded? do
        expect(monitor.description).to be_mongos
      end
    end

    context 'when the ismaster command fails' do

      context 'when no server is running on the address' do

        let(:bad_address) do
          Mongo::Address.new('127.0.0.1:27050')
        end

        let(:monitor) do
          described_class.new(bad_address, listeners)
        end

        before do
          monitor.scan!
        end

        it 'keeps the server unknown' do
          expect(monitor.description).to be_unknown
        end
      end

      context 'when the socket gets an exception' do

        let(:bad_address) do
          Mongo::Address.new(DEFAULT_ADDRESS)
        end

        let(:monitor) do
          described_class.new(bad_address, listeners)
        end

        let(:socket) do
          monitor.connection.connect!
          monitor.connection.__send__(:socket)
        end

        before do
          expect(socket).to receive(:write).and_raise(Mongo::Error::SocketError)
          monitor.scan!
        end

        it 'keeps the server unknown' do
          expect(monitor.description).to be_unknown
        end

        it 'disconnects the connection' do
          expect(monitor.connection).to_not be_connected
        end
      end
    end
  end

  describe '#run!' do

    let(:monitor) do
      described_class.new(address, listeners)
    end

    before do
      monitor.run!
      sleep(1)
    end

    it 'refreshes the server on the provided interval' do
      expect(monitor.description).to_not be_nil
    end
  end
end
