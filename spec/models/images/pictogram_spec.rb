require 'rails_helper'

RSpec.describe Pictogram, type: :model do
  subject { build(:pictogram) }


  context 'validations' do
    it { is_expected.to be_valid }
  end

  context 'methods' do
    let(:pictogram) { build(:pictogram) }

    describe '.find_like_by_and_locale' do
      let(:locale_1) { :pt }
      let(:locale_2) { :en }

      before(:each) do
        create(:pictogram, locale: locale_1)
        create(:pictogram, locale: locale_1)
        create(:pictogram, locale: locale_2)
      end

      after(:each) do
        Pictogram.destroy_all
      end

      it 'finds pictograms for first param key and the locale' do
        opts = { image_file_name: pictogram.image_file_name, locale: locale_1 }
        pictograms = Pictogram.find_like_by_and_locale(opts)
        expect(pictograms.size).to eq(2)
      end
    end

    describe '#attachment_path' do
      let(:path) { "#{ENV['FALAE_IMAGES_PATH']}/public/:id.:extension" }

      it 'returns the path to the pictogram' do
        expect(pictogram.attachment_path).to eq(path)
      end
    end

    describe '#attachment_url' do
      let(:url)  { '/assets/:id.:extension' }

      it 'returns the url to the pictogram' do
        expect(pictogram.attachment_url).to eq(url)
      end
    end

    describe '#generate_item' do
      let(:ext) { 'ext' }
      let(:image_file_name) { pictogram.image_file_name }
      let(:file_name) { 'file_name' }

      before(:each) do
        allow(File).to receive(:extname).with(image_file_name).and_return(ext)
        allow(File).to receive(:basename).with(image_file_name, ext)
                                         .and_return(file_name)
      end

      it 'generates an item for the pictogram' do
        item = pictogram.generate_item
        expect(pictogram).to eq(item.image)
      end
    end

    describe '#pictogram?' do
      it 'returns true' do
        expect(pictogram.pictogram?).to be_truthy
      end
    end
  end
end
