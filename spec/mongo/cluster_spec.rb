require 'spec_helper'

describe Mongo::Cluster do

  describe '#==' do

    let(:cluster) do
      described_class.new([ '127.0.0.1:27017' ])
    end

    context 'when the other is a cluster' do

      context 'when the addresses are the same' do

        context 'when the options are the same' do

          let(:other) do
            described_class.new([ '127.0.0.1:27017' ])
          end

          it 'returns true' do
            expect(cluster).to eq(other)
          end
        end

        context 'when the options are not the same' do

          let(:other) do
            described_class.new([ '127.0.0.1:27017' ], :replica_set => 'test')
          end

          it 'returns false' do
            expect(cluster).to_not eq(other)
          end
        end
      end

      context 'when the addresses are not the same' do

        let(:other) do
          described_class.new([ '127.0.0.1:27018' ])
        end

        it 'returns false' do
          expect(cluster).to_not eq(other)
        end
      end
    end

    context 'when the other is not a cluster' do

      it 'returns false' do
        expect(cluster).to_not eq('test')
      end
    end
  end

  describe '#inspect' do

    let(:preference) do
      Mongo::ServerSelector.get
    end

    let(:cluster) do
      described_class.new([ '127.0.0.1:27017' ])
    end

    it 'displays the cluster seeds and topology' do
      expect(cluster.inspect).to include('topology')
      expect(cluster.inspect).to include('servers')
    end
  end

  describe '#replica_set_name' do

    let(:preference) do
      Mongo::ServerSelector.get
    end

    let(:cluster) do
      described_class.new([ '127.0.0.1:27017' ], :replica_set => 'testing')
    end

    context 'when the option is provided' do

      let(:cluster) do
        described_class.new([ '127.0.0.1:27017' ], :replica_set => 'testing')
      end

      it 'returns the name' do
        expect(cluster.replica_set_name).to eq('testing')
      end
    end

    context 'when the option is not provided' do

      let(:cluster) do
        described_class.new([ '127.0.0.1:27017' ])
      end

      it 'returns nil' do
        expect(cluster.replica_set_name).to be_nil
      end
    end
  end

  describe '#scan!' do

    let(:preference) do
      Mongo::ServerSelector.get
    end

    let(:cluster) do
      described_class.new([ '127.0.0.1:27017' ])
    end

    let(:known_servers) do
      cluster.instance_variable_get(:@servers)
    end

    before do
      expect(known_servers.first).to receive(:scan!).and_call_original
    end

    it 'returns true' do
      expect(cluster.scan!).to be true
    end
  end
end
