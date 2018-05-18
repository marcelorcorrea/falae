require 'rails_helper'

RSpec.describe BaseCategory, type: :model do
  subject { build(:base_category) }

  context 'when having valid attributes' do
    it { is_expected.to be_valid }
  end

  context 'when having invalid attributes' do
    let(:base_category) { create(:base_category) }

    it 'does not allow base category with invalid name' do
      subject.name = nil
      expect(subject).to be_invalid
    end

    it 'does not allow base category with invalid color' do
      subject.color = nil
      expect(subject).to be_invalid
    end

    it 'does not allow a new base category with name already taken' do
      new_base_ctgy = build(:base_category, name: base_category.name)
      expect(new_base_ctgy).to be_invalid
    end

    it 'does not allow a new base category with color already taken' do
      new_base_ctgy = build(:base_category, color: base_category.color)
      expect(new_base_ctgy).to be_invalid
    end
  end
end
