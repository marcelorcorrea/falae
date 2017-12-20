class CreateCspReports < ActiveRecord::Migration[5.1]
  def change
    create_table :csp_reports do |t|
      t.string :user_agent
      t.string :blocked_uri
      t.string :document_uri
      t.string :effective_directive
      t.text :original_policy, limit: 1024
      t.string :referrer
      t.string :script_sample
      t.string :source_file
      t.integer :status_code
      t.string :violated_directive

      t.timestamps
    end
  end
end
