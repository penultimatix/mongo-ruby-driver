require 'spec_helper'

describe Mongo::Collection::View::Explainable do

  let(:selector) do
    {}
  end

  let(:options) do
    {}
  end

  let(:view) do
    Mongo::Collection::View.new(authorized_collection, selector, options)
  end

  after do
    authorized_collection.find.remove_many
  end

  describe '#explain' do

    let(:explain) do
      view.explain
    end

    it 'executes an explain' do
      expect(explain[:cursor]).to eq('BasicCursor')
    end
  end
end
