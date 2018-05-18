require 'rails_helper'

RSpec.describe Item, type: :model do
  subject { build(:item) }
  let(:item) { build(:item) }

  before(:each) do
    allow(UserMailer).to receive_message_chain(:account_activation, :deliver_now)
  end

  after(:each) do
    Pictogram.destroy_all
    User.destroy_all
  end

  context 'validations' do
    context 'when having valid attributes' do
      it { is_expected.to be_valid }
    end

    context 'when having invalid attributes' do
      it'does not allow item without category' do
        subject.category = nil
        expect(subject).to be_invalid
      end

      it'does not allow item without image' do
        subject.image = nil
        expect(subject).to be_invalid
      end

      it'does not allow item without user' do
        subject.user = nil
        expect(subject).to be_invalid
      end

      it'does not allow item without name' do
        subject.name = nil
        expect(subject).to be_invalid
      end

      it'does not allow item without speech' do
        subject.speech = nil
        expect(subject).to be_invalid
      end
    end
  end

  context 'methods' do
    describe 'build_image' do
      let(:img_path) { "#{Rails.root}/spec/support/images/other_image.png" }
      let(:new_img) { File.new(img_path) }
      let(:pictogram) { build(:pictogram, image: new_img) }

      it 'updates the image associated to the item' do
        item.build_image(image: new_img)
        expect(item.image.image_file_name).to eq(pictogram.image_file_name)
      end

      it 'creates a private image for item if there is no image' do
        item.image = nil
        item.build_image(image: new_img)
        expect(item.image.type).to eq('PrivateImage')
      end

      context 'when there is an image associated to item' do
        let(:image) { double('image') }

        before(:each) do
          allow(image).to receive(:update)
          allow(item).to receive(:image).and_return(image)
        end

        it 'updates the image with the params passed' do
          item.build_image(image: new_img)
          expect(image).to have_received(:update).with(image: new_img)
        end
      end

      context 'when there is no image associated to item' do
        let(:image) { double('image') }

        before(:each) do
          allow(item).to receive(:image).and_return(nil)
          allow(PrivateImage).to receive(:create).and_return(image)
          allow(image).to receive(:valid?).and_return(true)
          allow(image).to receive(:cropping?).and_return(true)
          allow(image).to receive(:reprocess_image)
          allow(item).to receive(:image=)
        end


        it 'creates a new Private Image with the params passed' do
          item.build_image(image: new_img)
          expect(PrivateImage).to have_received(:create).with(image: new_img)
        end

        it 'calls reprocess_image of image if it is valid and has crop options' do
          item.build_image(image: new_img)
          expect(image).to have_received(:reprocess_image)
        end

        it 'does not call reprocess_image of image if it is not valid' do
          allow(image).to receive(:valid?).and_return(false)
          item.build_image(image: new_img)
          expect(image).not_to have_received(:reprocess_image)
        end

        it 'does not call reprocess_image of image if it is missing any crop options' do
          allow(image).to receive(:cropping?).and_return(false)
          item.build_image(image: new_img)
          expect(image).not_to have_received(:reprocess_image)
        end

        it 'assings the created image to item image attribute' do
          item.build_image(image: new_img)
          expect(item).to have_received(:image=).with(image)
        end
      end
    end

    describe 'image?' do
      it 'returns true if there is an image associate to' do
        expect(item.image?).to be_truthy
      end

      it 'returns true if there is no image associate to' do
        item.image.image = nil
        expect(item.image?).to be_falsy
      end
    end

    describe 'image_attributes=' do
      let(:img)  { create(:private_image) }

      # after(:each) do
      #   PrivateImage.destroy_all
      # end

      it 'updates image item with retrieved image from passed id' do
        item.image_attributes = { id: img.id }
        expect(item.image).to eq(img)
      end

      context 'when not passing id key in parameter hash' do
        before(:each) do
          allow(Image).to receive(:find_by)
          allow(item).to receive(:update)
          item.image_attributes = { }
        end

        it 'does not try to find an image' do
          expect(Image).not_to have_received(:find_by)
        end

        it 'does not update image item attribute' do
          expect(item).not_to have_received(:update)
        end
      end

      context 'when passing id key in parameter hash' do
        let(:id) { 1 }
        let(:image) { double('image') }

        before(:each) do
          allow(Image).to receive(:find_by).and_return(image)
          allow(item).to receive(:update)
          item.image_attributes = { id: id }
        end

        it 'finds an image with id' do
          expect(Image).to have_received(:find_by).with(id: id)
        end

        it 'updates image item attribute with image found' do
          expect(item).to have_received(:update).with(image: image)
        end
      end
    end

    describe '#in_page?' do
      let(:pages) { build_list(:page, 2) }

      it 'returns true if item has pages and pages include the page' do
        item.pages = pages
        expect(item.in_page?(pages[0])).to be true
      end

      it 'returns false if item does not have pages' do
        expect(item.in_page?(pages[0])).to be false
      end

      it 'returns false if item has pages but does not include the page' do
        item.pages = pages
        expect(item.in_page?(build(:page))).to be false
      end
    end
  end
end
