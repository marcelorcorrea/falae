require 'rails_helper'

RSpec.describe User, type: :model  do
  subject { build(:user) }

  let(:user) { build(:user) }

  before(:each) do
    allow(UserMailer).to receive_message_chain(:account_activation, :deliver_now)
  end

  context 'validations'  do

    context 'when having valid attributes'  do
      it { is_expected.to be_valid }
    end

    context 'when having invalid attributes'  do
      it 'does not allow user without name'  do
        subject.name = nil
        expect(subject).to be_invalid
      end

      it 'does not allow user with name greater than 50 characters'  do
        subject.name = 'user_name' * 10
        expect(subject).to be_invalid
      end

      it 'does not allow user without last_name'  do
        subject.last_name = nil
        expect(subject).to be_invalid
      end

      it 'does not allow user with last_name greater than 50 characters'  do
        subject.last_name = 'user_last_name' * 10
        expect(subject).to be_invalid
      end

      it 'does not allow user without email'  do
        subject.email = nil
        expect(subject).to be_invalid
      end

      it 'does not allow another user with email already taken'  do
        user = create(:user)
        opts_other_user = {
          name: 'name',
          last_name: 'last_name',
          email: user.email.upcase,
          password: 'password',
          locale: 'en'
        }
        other_user = build(:user, opts_other_user)
        expect(other_user).to be_invalid
      end

      it 'does not allow user email with more than 255 characters'  do
        email_id = 'email_id' * 50
        subject.email = "#{email_id}@falae.com"
        expect(subject).to be_invalid
      end

      it 'does not allow user email with invalid format'  do
        subject.email = 'user_email.com'
        expect(subject).to be_invalid
      end

      it 'does not allow user without locale'  do
        subject.locale = nil
        expect(subject).to be_invalid
      end

      it 'does not allow user with locale is not in supported locales'  do
        subject.locale = 'unsupported_locale'
        expect(subject).to be_invalid
      end

      it 'does not allow user without password'  do
        subject.password = nil
        expect(subject).to be_invalid
      end

      it 'does not allow user password less than 6 characters'  do
        subject.password = nil
        expect(subject).to be_invalid
      end

      it 'does not allow photo attached file with invalid extension'  do
        file = File.new("#{Rails.root}/spec/support/images/image.txt")
        expect(build(:user, photo: file)).to be_invalid
      end
    end
  end

  context 'methods'  do
    describe '.cleanup_unactivated'  do
      it 'deletes not activated users older than User::UNACTIVATED_TTL'  do
        created_at = User::UNACTIVATED_TTL - 1.day
        create(:user, activated: true)
        create(:user, activated: false)
        create(:user, activated: false, created_at: created_at)
        User.cleanup_unactivated
        expect(User.count).to eq(2)
      end
    end

    describe '.digest'  do
      context 'returns a hash of a given string'  do
        let(:str) { 'digest' }
        let(:cost) { 'cost' }

        before(:each) do
          allow(BCrypt::Password).to receive(:create)
        end

        it 'creates with BCrypt::Engine::MIN_COST if ActiveModel::SecurePassword.min_cost'  do
          User.digest(str)
          expect(BCrypt::Password).to have_received(:create)
          .with(str, cost: BCrypt::Engine::MIN_COST)
        end

        it 'creates with BCrypt::Engine.cost unless ActiveModel::SecurePassword.min_cost'  do
          allow(ActiveModel::SecurePassword).to receive(:min_cost).and_return(nil)
          allow(BCrypt::Engine).to receive(:cost).and_return(cost)
          User.digest(str)
          expect(BCrypt::Password).to have_received(:create)
            .with(str, cost: cost)
        end
      end
    end

    describe '.new_token'  do
      it 'generates a new base64 token'  do
        allow(SecureRandom).to receive(:urlsafe_base64)
        User.new_token
        expect(SecureRandom).to have_received(:urlsafe_base64)
      end
    end

    describe '.with_unexpired_auth_token'  do
      it 'gets the first user with the auth token and within the period'  do
        opts = {
          auth_token: SecureRandom.urlsafe_base64,
          auth_token_created_at: 10.minute.ago
        }
        user_1 = create(:user, opts)
        user_2 = create(:user, opts)
        user = User.with_unexpired_auth_token(opts[:auth_token], 1.minute)
        expect(user).to eq(user_1)
      end
    end

    describe '#activate'  do
      let(:user) { create(:user) }
      let(:time_zone) { Time.zone }
      let(:now) { time_zone.now }

      before(:each) do
        allow(time_zone).to receive(:now).and_return(now)
        allow(Time).to receive(:zone).and_return(time_zone)
      end

      it 'updates the user activated status to true'  do
        user.activate
        expect(user.activated).to be_truthy
      end

      it 'calls update with activated true and current time'  do
        allow(user).to receive(:update)
        user.activate
        expect(user).to have_received(:update)
          .with(activated: true, activated_at: now)
      end
    end

    describe '#authentic_token?'  do
      let(:attribute) { :password }
      let(:token) { :token }
      let(:attr_digest) { "#{attribute}_digest" }

      it 'returns false if user does not have digest attribute'  do
        allow(user).to receive(:send).with(attr_digest).and_return(nil)
        auth_token = user.authentic_token?(attribute, token)
        expect(auth_token).to be_falsy
      end

      it 'returns true if user have digest attribute and it is the password'  do
        digest_token = 'digest_token'
        digest = double('digest')
        allow(user).to receive(:send).with(attr_digest).and_return(digest_token)
        allow(BCrypt::Password).to receive(:new).with(digest_token)
        .and_return(digest)
        allow(digest).to receive(:is_password?).with(token).and_return(true)
        auth_token = user.authentic_token?(attribute, token)
        expect(auth_token).to be_truthy
      end
    end

    describe '#authenticate!'  do
      let(:attribute) { :attribute }

      context "when password passed is user's password"  do
        before(:each) do
          allow(user).to receive(:authenticate).with(user.password)
            .and_return(user)
        end

        it 'returns the user'  do
          expect(user.authenticate!(user.password, attribute)).to eq(user)
        end

        it 'should not add error to model erros'  do
          user.authenticate!(user.password, attribute)
          expect(user.errors).to be_empty
        end
      end

      context 'with incorrect password'  do
        let(:wrong_password) { 'wrong password' }
        let(:message) { 'message' }

        before(:each) do
          allow(user).to receive(:authenticate).with(wrong_password)
            .and_return(false)
        end

        it "returns false if password passed is user's password"  do
          expect(user.authenticate!(wrong_password, attribute)).to be_falsy
        end

        it "adds error to model erros"  do
          errors = spy('erros')
          allow(errors).to receive(:add)
          allow(user).to receive(:errors).and_return(errors)
          user.authenticate!(wrong_password, attribute, message)
          expect(errors).to have_received(:add).with(attribute, message)
        end
      end
    end

    describe '#create_reset_digest'  do
      let(:token) { 'token' }
      let(:digest) { 'digest' }
      let(:time_zone) { Time.zone }
      let(:now) { time_zone.now }

      before(:each) do
        allow(User).to receive(:new_token).and_return(token)
        allow(User).to receive(:digest).with(token).and_return(digest)
        allow(time_zone).to receive(:now).and_return(now)
        allow(Time).to receive(:zone).and_return(time_zone)
      end

      it 'updates reset_digest column with new digest token'  do
        user.create_reset_digest
        expect(user.reset_digest).to eq(digest)
      end

      it 'updates reset_sent_at column with new time'  do
        user.create_reset_digest
        expect(user.reset_sent_at).to eq(now)
      end

      it 'calls update_columns with activated true and current time'  do
        allow(user).to receive(:update)
        user.create_reset_digest
        expect(user).to have_received(:update)
          .with(reset_digest: digest, reset_sent_at: now)
      end
    end

    describe '#cropping?'  do
      it 'returns true if all of crop attributes are truthy values'  do
        crop_options = { crop_x: 0, crop_y: 0, crop_w: 500, crop_h: 500 }
        user = build(:user, crop_options)
        expect(user.cropping?).to be_truthy
      end

      it 'returns false if any of crop attributes is not truthy value'  do
        crop_options = { crop_x: 0, crop_y: 0, crop_w: nil, crop_h: nil }
        user = build(:user, crop_options)
        expect(user.cropping?).to be_falsy
      end
    end

    describe '.find_items_like_by' do
      let(:img) { create(:private_image, user: user, image_file_name: 'img_1') }
      let(:base_ctgy) { create(:base_category) }
      let(:category) { create(:category, base_category: base_ctgy)}
      let(:item_opts) do
        {
          category: category,
          user: user,
          image: img,
          image_type: 'PrivateImage'
        }
      end
      let(:name_to_search) { 'item_to_retrive' }

      before(:each) do
        create(:item, item_opts.merge(name: name_to_search))
        create(:item, item_opts.merge(name: 'other_item'))
        create(:item, item_opts.merge(name: "#{name_to_search}_something_else"))
      end

      after(:each) do
        PrivateImage.destroy_all
      end

      it 'finds user items with first hash key value passed as parameter' do
        opts = { name: name_to_search }
        items = user.find_items_like_by(name: name_to_search)
        expect(items.size).to eq(2)
      end
    end

    describe '#revalidate_token_access'  do
      before(:each) do
        allow(user).to receive(:regenerate_auth_token)
        allow(user).to receive(:touch)
        user.revalidate_token_access
      end

      it 'regenerates the auth token'  do
        expect(user).to have_received(:regenerate_auth_token)
      end

      it 'update the :auth_token_created_at column'  do
        expect(user).to have_received(:touch).with(:auth_token_created_at)
      end
    end

    describe '#send_activation_email'  do
      let(:account_activation) { double('account activation') }

      before(:each) do
        allow(account_activation).to receive(:deliver_now)
        allow(UserMailer).to receive(:account_activation).with(user)
          .and_return(account_activation)
        user.send_activation_email
      end

      it "retrieve user's activation account"  do
        expect(UserMailer).to have_received(:account_activation)
      end

      it "sends an activation link to the user's email"  do
        expect(account_activation).to have_received(:deliver_now)
      end
    end

    describe '#send_password_reset_email'  do
      let(:password_reset) { double('account activation') }

      before(:each) do
        allow(password_reset).to receive(:deliver_now)
        allow(UserMailer).to receive(:password_reset).with(user)
          .and_return(password_reset)
        user.send_password_reset_email
      end

      it "retrieve user's password reset"  do
        expect(UserMailer).to have_received(:password_reset)
      end

      it "sends an password reset link to the user's email"  do
        expect(password_reset).to have_received(:deliver_now)
      end
    end

    describe '#password_reset_expired?'  do
      it 'returns true if reset_sent_at is greater than two hours'  do
        user.reset_sent_at = 3.hours.ago
        expect(user.password_reset_expired?).to be_truthy
      end

      it 'returns false if reset_sent_at is less than two hours'  do
        user.reset_sent_at = 1.hour.ago
        expect(user.password_reset_expired?).to be_falsy
      end
    end

    describe '#update_password_with_context'  do
      let(:user) { create(:user) }
      let(:passaword_params) { {
                                  password: 'new_password',
                                  password_confirmation: 'new_password'
                                }
                              }

      it "updates user's passaword"  do
        user.update_password_with_context passaword_params
        authenticated = user.authenticate(passaword_params[:password])
        expect(authenticated).to eq(user)
      end

      it 'saves with specific context to run validations'  do
        allow(user).to receive(:with_transaction_returning_status).and_yield
        allow(user).to receive(:save)
        user.update_password_with_context passaword_params
        expect(user).to have_received(:save).with(context: :update_password)
      end
    end

    describe '#reprocess_photo' do
      let(:crop_attr) { { crop_x: 0, crop_y: 0, crop_w: 10, crop_h: 10 } }
      let(:photo) { double('photo') }
      # let(:photo) { File.new("#{Rails.root}/spec/support/images/user.png") }

      before(:each) do
        allow(photo).to receive(:reprocess!)
        allow(user).to receive(:photo).and_return(photo)
        user.reprocess_photo
      end

      it 'reprocesses the user photo if all crop attributes are set' do
        expect(photo).to have_received(:reprocess!)
      end
    end
  end
end
