require 'rails_helper'

RSpec.describe Image, type: :model  do
  context 'validations'  do
    subject { build(:image) }

    context 'when having valid attributes'  do
      it { is_expected.to be_valid }
    end

    context 'when having invalid attributes'  do
      it 'does not allow image with invalid locale'  do
        subject.locale = nil
        expect(subject).to be_invalid
      end

      it 'does not allow image without attached image file'  do
        expect(build(:image, image: nil)).to be_invalid
      end

      it 'does not allow image attached file with invalid extension'  do
        file = File.new("#{Rails.root}/spec/support/images/image.txt")
        expect(build(:image, image: file)).to be_invalid
      end
    end
  end

  context 'methods'  do
    let(:image) { build(:image) }

    describe '#attachment_path'  do
      it 'raises error'  do
        expect { image.attachment_path }.to raise_error(NotImplementedError)
      end
    end

    describe '#cropping?'  do
      it 'returns true if all of crop attributes are truthy values'  do
        crop_options = { crop_x: 0, crop_y: 0, crop_w: 500, crop_h: 500 }
        img = build(:image, crop_options)
        expect(img.cropping?).to be_truthy
      end

      it 'returns false if any of crop attributes is not truthy value'  do
        crop_options = { crop_x: 0, crop_y: 0, crop_w: nil, crop_h: nil }
        img = build(:image, crop_options)
        expect(img.cropping?).to be_falsy
      end
    end

    describe '#image_remote_url='  do
      let(:url) { "file://#{Rails.root}/spec/support/images/image.png" }

      before(:each) do
        allow(image).to receive(:image=).with(URI.parse(url))
      end

      it 'sets image url'  do
        image.image_remote_url = url
        expect(image.image_remote_url).to eq(url)
      end
    end

    describe '#pictogram?'  do
      it 'returns false'  do
        expect(image.pictogram?).to be_falsy
      end
    end

    describe '#private?'  do
      it 'returns false'  do
        expect(image.private?).to be_falsy
      end
    end

    describe '#reprocess_image'  do
      it 'calls reprocess! method of attached image attribute'  do
        expect(image).to receive_message_chain(:image, :reprocess!)
        image.reprocess_image
      end
    end
  end
end
