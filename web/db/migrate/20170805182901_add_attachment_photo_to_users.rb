class AddAttachmentPhotoToUsers < ActiveRecord::Migration[5.1]
  def self.up
    change_table :users do |t|
      t.attachment :photo
    end
  end

  def self.down
    remove_attachment :users, :photo
  end
end
