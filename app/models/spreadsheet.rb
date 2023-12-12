require File.join(Rails.root, "lib", "encryption_service.rb")

class Spreadsheet < ApplicationRecord
  belongs_to :user
  has_many :pages, dependent: :destroy

  # validates_associated :user
  validates :name, presence: true, uniqueness: { scope: :user }
  # TODO: validate existence of referenced initial_page when assign new value

  def export_as_json
    self.as_json(
      only: [:name, :initial_page],
      include: {
        pages: {
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
        }
      }
    )
  end

  def export(include_private_items = false)
    spreadsheet = self.export_as_json
    if !include_private_items
      spreadsheet['pages'].each do |page|
        page['items'] = page['items'].select do |i|
          i['image']['type'] != PrivateImage.name
        end
      end
    end
    EncryptionService.encrypt spreadsheet.to_json
  end

  def self.import(spreadsheet_encrypted, user)
    spreadsheet_json = EncryptionService.decrypt spreadsheet_encrypted
    parsed_spreadsheet = JSON.parse spreadsheet_json

    Spreadsheet.transaction do
      spreadsheet = Spreadsheet.create! name: parsed_spreadsheet['name'],
        initial_page: parsed_spreadsheet['initial_page'],
        user_id: user.id

      parsed_spreadsheet['pages'].each do |page|
        error = Page.import!(page, spreadsheet, spreadsheet.user, serialized: true)
      end
      nil
    end
  rescue
    I18n.t 'errors.invalid_file'
  end
end
