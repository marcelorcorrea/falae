require 'rails_helper'

RSpec.describe Role, type: :model  do
  context 'validations'  do
    subject { build(:role) }

    context 'when having valid attributes'  do
      it { is_expected.to be_valid }
    end

    context 'when having invalid attributes'  do
      it 'does not allow role without name'  do
        subject.name = nil
        expect(subject).to be_invalid
      end
    end
  end

  context 'methods'  do
    describe '.default'  do
      it 'returns the default role'  do
        create(:role)
        expect(Role.default.name).to eq(Role::DEFAULT_ROLE_NAME)
      end
    end
  end
end
