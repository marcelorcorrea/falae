require 'rails_helper'

RSpec.describe Spreadsheet, type: :model do
  subject { build(:spreadsheet) }

  before(:each) do
    allow(UserMailer).to receive_message_chain(:account_activation, :deliver_now)
  end

  context 'validations' do
    context 'when having valid attributes' do
      it { is_expected.to be_valid }

      it 'has same name but different user' do
        create(:spreadsheet)
        expect(subject).to be_valid
      end
    end

    context 'when having invalid attributes' do
      it 'does not allow spreadsheet without name' do
        subject.name = nil
        expect(subject).to be_invalid
      end

      it 'does not allow spreadsheet with name already take for same user' do
        sp = create(:spreadsheet, name: subject.name, user: subject.user)
        expect(subject).to be_invalid
      end
    end
  end
end
