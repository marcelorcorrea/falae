require 'rails_helper'

RSpec.describe Category, type: :model do
  context 'validations'  do
    subject { build(:category) }

    context 'when it has valid attributes'  do
      it { is_expected.to be_valid }
    end

    context 'when it has invalid attributes'  do
      it 'does not allow category without base category'  do
        subject.base_category = nil
        expect(subject).to be_invalid
      end

      it 'does not allow category with invalid description'  do
        subject.description = nil
        expect(subject).to be_invalid
      end

      it 'does not allow category with invalid locale'  do
        subject.locale = nil
        expect(subject).to be_invalid
      end
    end
  end

  context 'methods'  do
    let(:ctgy_attrs) { { base_category: base_ctgy, locale: locale } }

    describe '.all_by_current_locale'  do
      let(:locale) { 'locale' }
      let(:total_ctgy) { 3 }
      let(:base_ctgy) { create(:base_category) }

      before(:each) do
        allow(I18n).to receive(:locale).and_return(locale)
        create_list(:category, total_ctgy, ctgy_attrs)
      end

      it 'returns all categories for the current locale'  do
        expect(Category.all_by_current_locale.count).to eq(total_ctgy)
      end
    end

    describe '.default'  do
      let(:locale) { 'locale' }
      let(:total_ctgy) { 3 }
      let(:base_ctgy) { create(:base_category, name: 'OTHER') }

      let!(:default_ctgy) { create(:category, ctgy_attrs) }

      before(:each) do
        allow(I18n).to receive(:locale).and_return(locale)
      end

      it 'returns the default category for the current locale'  do
        expect(Category.default).to eq(default_ctgy)
      end
    end
  end
end
