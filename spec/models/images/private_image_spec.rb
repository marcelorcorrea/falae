require 'rails_helper'

RSpec.describe PrivateImage, type: :model do
  subject { build(:private_image) }

  before(:each) do
    allow(UserMailer).to receive_message_chain(:account_activation, :deliver_now)
  end

  context 'validations' do
    it { is_expected.to be_valid }
  end

  context 'methods' do
    let(:private_image) { build(:private_image) }
    let(:user_id) { private_image.user.id }

    after(:each) do
      User.destroy_all
    end

    describe '#attachment_path' do
      let(:path) { "#{ENV['FALAE_IMAGES_PATH']}/private/user_#{user_id}/:id.:extension" }

      it 'returns the path to the private image' do
        expect(private_image.attachment_path).to eq(path)
      end
    end

    describe '#attachment_url' do
      let(:item) { double('item', id: 1) }
      let(:url) { "/users/#{user_id}/items/#{item.id}/image" }

      before(:each) do
        allow(private_image).to receive(:item).and_return(item)
      end

      it 'returns the url to the private image' do
        expect(private_image.attachment_url).to eq(url)
      end
    end

    describe '#private?' do
      it 'returns true' do
        expect(private_image.private?).to be_truthy
      end
    end
  end
end
