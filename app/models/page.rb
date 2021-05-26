require File.join(Rails.root, "lib", "encryption_service.rb")

class Page < ApplicationRecord
  belongs_to :spreadsheet
  has_many :item_pages, dependent: :destroy
  has_many :items, -> { select 'items.*, item_pages.link_to, '\
                               'item_pages.id AS item_page_id' },
           through: :item_pages

  validates_associated :spreadsheet
  validates :name, presence: true, uniqueness: { scope: :spreadsheet }
  validates :columns, :rows,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :columns, numericality: { less_than_or_equal_to: 10 }

  after_save do
    if spreadsheet.initial_page == name_before_last_save || spreadsheet.pages.count == 1
      spreadsheet.update(initial_page: name)
    end
  end

  after_destroy do
    spreadsheet.update(initial_page: nil) if name == spreadsheet.initial_page
  end

  def get_linked_page_id(item_id)
    item_page = ItemPage.find_by(page_id: id, item_id: item_id)
    return nil unless item_page
    linked_page = spreadsheet.pages.find_by(name: item_page.link_to)
    linked_page&.id
  end

  def swap_items(id1, id2)
    ip1, ip2 = item_pages.where(item_id: [id1, id2])
    return false unless ip1 && ip2
    ip1_item_id = ip1.item_id
    ip1_link_to = ip1.link_to
    Page.transaction do
      u1 = ip1.update(item_id: ip2.item_id, link_to: ip2.link_to)
      u2 = ip2.update(item_id: ip1_item_id, link_to: ip1_link_to)
      raise ActiveRecord::Rollback unless u1 && u2
      true
    end
  end

  def export_as_json
    self.as_json(
      only: [:name, :columns, :rows, :spreadsheet_id],
      include: {
        items: {
          only: [:id, :name, :speech, :category_id],
          include: {
            image: {
              only: [:id, :type]
            }
          }
        }
      }
    )
  end

  def export(include_private_items = false)
    page = self.export_as_json
    if !include_private_items
      page['items'] = page['items'].select { |i| i['image']['type'] != PrivateImage.name }
    end
    EncryptionService.encrypt page.to_json
  end

  def private_items?
    items.any? { |item| item.private? }
  end

  def self.import!(page_data, spreadsheet, user, opts = {})
    parsed_page = if !opts[:serialized]
      page_json  = EncryptionService.decrypt page_data
      JSON.parse(page_json)
    else
      page_data
    end

    Page.transaction do
      page = Page.create! name: parsed_page['name'],
        columns: parsed_page['columns'],
        rows: parsed_page['rows'],
        spreadsheet: spreadsheet

      parsed_page['items'].each do |item|
        img = if item['image']['type'] == Pictogram.name
          Image.find item['image']['id']
        else
          private_image = Image.find(item['image']['id'])
          img_dup = private_image.dup
          img_dup.image = private_image.image
          img_dup.user_id = user.id
          img_dup
        end
        page.items.create! name: item['name'],
          speech: item['speech'],
          category_id: item['category_id'],
          user: user,
          image: img
      end
    end
  end

  def self.import(page_encrypted, spreadsheet, user)
    import! page_encrypted, spreadsheet, user
    nil
  rescue ActiveSupport::MessageVerifier::InvalidSignature, JSON::ParserError => ex
    I18n.t 'errors.invalid_file'
  rescue ActiveRecord::RecordInvalid => ex
    ex.message
  end
end
