require 'rails_helper'

RSpec.describe ItemPage, type: :model do
  subject { build(:item_page) }

  before(:each) do
    allow(UserMailer).to receive_message_chain(:account_activation, :deliver_now)
  end

  it { is_expected.to be_valid }

  context 'when having link_to attribute' do
    let(:item_page) { build(:item_page) }
    let(:linked_page_name) { ':linked_page_name' }

    before(:each) do
      item_page.link_to = linked_page_name
    end

    it 'returns the linked page name' do
      expect(item_page.link_to).to eq(linked_page_name)
    end
  end
end
