require 'rails_helper'

RSpec.describe Current do
  let(:client1) { instance_double(Client, name: 'Client1') }
  let(:client2) { instance_double(Client, name: 'Client2') }

  describe '#with_client' do
    it 'sets the client within the block and restores it after' do
      Current.client = client1
      Current.with_client(client2) do
        expect(Current.client).to eq(client2)
      end
      expect(Current.client).to eq(client1)
    end

    it 'restores the previous client even if an error is raised' do
      Current.client = client1
      expect { Current.with_client(client2) { raise "error" } }.to raise_error("error")
      expect(Current.client).to eq(client1)
    end
  end
end
