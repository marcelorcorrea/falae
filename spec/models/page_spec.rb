require 'rails_helper'

RSpec.describe Page, type: :model do
  subject { build(:page) }

  let(:created_page) { create(:page) }

  before(:each) do
    allow(UserMailer).to receive_message_chain(:account_activation, :deliver_now)
  end

  context 'validations' do
    context 'when having valid attributes' do
      it { is_expected.to be_valid }

      it 'has same name but different spreadsheet' do
        create(:page, name: subject.name)
        expect(subject).to be_valid
      end
    end

    context 'when having invalid attributes' do
      it'does not allow page without spreadsheet' do
        subject.spreadsheet = nil
        expect(subject).to be_invalid
      end

      it 'does not allow page with name already take for same spreadsheet' do
        sp = create(:page, name: subject.name, spreadsheet: subject.spreadsheet)
        expect(subject).to be_invalid
      end

      it 'does not allow page without name' do
        subject.name = nil
        expect(subject).to be_invalid
      end

      it 'does not allow page without columns' do
        subject.columns = nil
        expect(subject).to be_invalid
      end

      it 'does not allow page with columns that is not integer' do
        subject.columns = 'string'
        expect(subject).to be_invalid
      end

      it 'does not allow page with columns equals to zero' do
        subject.columns = 0
        expect(subject).to be_invalid
      end

      it 'does not allow page with columns less than zero' do
        subject.columns = -1
        expect(subject).to be_invalid
      end

      it 'does not allow page with columns greater than ten' do
        subject.columns = 11
        expect(subject).to be_invalid
      end

      it 'does not allow page without rows' do
        subject.rows = nil
        expect(subject).to be_invalid
      end

      it 'does not allow page with rows that is not integer' do
        subject.rows = 'string'
        expect(subject).to be_invalid
      end

      it 'does not allow page with rows equals to zero' do
        subject.rows = 0
        expect(subject).to be_invalid
      end

      it 'does not allow page with rows less than zero' do
        subject.rows = -1
        expect(subject).to be_invalid
      end
    end
  end

  context 'callbacks' do
    it 'assigns spreasheet initial page if it is the only spreadsheet page' do
      spreadsheet = created_page.spreadsheet
      expect(spreadsheet.initial_page).to eq(created_page.name)
    end

    it 'sets spreasheet initial page to nil if it is last spreadsheet page' do
      spreadsheet = created_page.spreadsheet
      created_page.destroy
      expect(spreadsheet.initial_page).to be_nil
    end

    it 'updates spreadsheet initial page name if it is the initial page' do
      spreadsheet = created_page.spreadsheet
      created_page.update(name: 'updated_name')
      expect(spreadsheet.initial_page).to eq(created_page.name)
    end
  end

  context 'methods' do
    let!(:page) { create(:page) }

    describe '#get_linked_page_id' do
      let(:linked_page_name) { 'linked_page_name' }
      let!(:item) { create(:item) }
      let!(:item_not_in_page) { create(:item, name: 'other') }
      let!(:linked_page) { create(:page,
                                  name: linked_page_name,
                                  spreadsheet: page.spreadsheet) }
      let!(:linked_page_another_spreadsheet) { create(:page,
                                                      name: linked_page_name) }

      before(:each) do
        create(:item_page, item: item, page: page, link_to: linked_page_name)
      end

      it 'returns the if of item linked page if it is set' do
        expect(page.get_linked_page_id(item.id)).to eq(linked_page.id)
      end

      it 'returns nil if the page does not have the item' do
        expect(page.get_linked_page_id(item_not_in_page.id)).to be_nil
      end

      it 'returns nil if the page spreadsheet does not have the linked page' do
        lpas = page.get_linked_page_id(linked_page_another_spreadsheet.id)
        expect(lpas).to be_nil
      end
    end

    describe '#swap_items' do
      let!(:item_1) { create(:item, :get_associations) }
      let!(:item_2) { create(:item, :get_associations) }

      before(:each) do
        page.items.push(item_1, item_2)
      end

      it 'swaps items id of two ItemPage of the page' do
        ip1, ip2 = page.item_pages.where(item_id: [item_1.id,item_2.id])
        page.swap_items(item_1.id, item_2.id)
        [ip1,ip2].each(&:reload)
        expect([ip1.item_id, ip2.item_id]).to eq([item_2.id, item_1.id])
      end

      it 'returns false if page does not have any of items' do
        page.items.last.destroy
        expect(page.swap_items(item_1.id, item_2.id)).to be_falsy
      end

      it 'returns false if it does not update any of items' do
        allow_any_instance_of(ItemPage).to receive(:update).and_return(false)
        expect(page.swap_items(item_1.id, item_2.id)).to be_falsy
      end
    end
  end
end
