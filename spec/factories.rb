FactoryBot.define do
  factory :base_category do
    sequence(:name) { |idx| "base_category_name_#{idx}" }
    sequence(:color) { |idx| "base_category_color_#{idx}" }
  end

  factory :category do
    description { 'category_description' }
    locale { 'category_locale' }
    base_category
  end

  factory :csp_report do
    user_agent { 'csp_report_user_agent' }
    blocked_uri  { 'csp_report_blocked_uri' }
    document_uri { 'csp_report_document_uri' }
    effective_directive { 'csp_report_effective_directive' }
    original_policy { 'csp_report_original_policy' }
    referrer { 'csp_report_referrer' }
    script_sample { 'csp_report_script_sample' }
    source_file { 'csp_report_source_file' }
    status_code { 'csp_report_status_code' }
    violated_directive { 'csp_report_violated_directive' }
  end

  factory :image do
    type { 'Image' }
    locale { 'en' }
    image { File.new("#{Rails.root}/spec/support/images/image.png") }
  end

  factory :item do
    name { 'item_name' }
    speech { 'item_speech' }
    image_type { 'Pictogram' }
    private { false }
    category
    association :image, factory: :pictogram
    user

    trait :get_associations do
      category { Category.first || create(:category) }
      user { User.first || create(:user) }
      image { Pictogram.first || create(:pictogram) }
    end
  end

  factory :item_page do
    link_to { nil }
    item
    page
  end

  factory :page do
    sequence(:name) { |idx| "page_name_#{idx}" }
    columns { 4 }
    rows { 3 }
    spreadsheet
  end

  factory :pictogram do
    type { 'Pictogram' }
    locale { 'en' }
    image { File.new("#{Rails.root}/spec/support/images/image.png") }
  end

  factory :private_image do
    type { 'PrivateImage' }
    locale { 'en' }
    image { File.new("#{Rails.root}/spec/support/images/image.png") }
    user
  end

  factory :spreadsheet do
    sequence(:name) { |idx| "spreadsheet_name_#{idx}" }
    initial_page { 'spreadsheet_initial_page' }
    user
  end

  factory :user do
    name { 'user_name' }
    last_name { 'user_last_name' }
    sequence(:email) { |n| "user_email_#{n}@falae.com" }
    password { 'user_password' }
    profile { 'user_profile' }
    locale { 'en' }
    photo { File.new("#{Rails.root}/spec/support/images/user.png") }

    factory :user_with_items do
      transient do
        items_count { 1 }
      end

      after(:create) do |user, evaluator|
        create_list(:item, evaluator.items_count, user: user)
      end
    end

    factory :user_with_pages do
      transient do
        pages_count { 1 }
      end

      after(:create) do |user, evaluator|
        create_list(:page, evaluator.pages_count,
          spreadsheet: create(:spreadsheet, user: user))
      end
    end
  end
end
