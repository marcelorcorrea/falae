class CreateCspReports < ActiveRecord::Migration[5.1]
  def change
    create_table :csp_reports do |t|
      t.text :user_agent
      t.text :blocked_uri
      t.text :document_uri
      t.text :effective_directive
      t.text :original_policy
      t.text :referrer
      t.text :script_sample
      t.text :source_file
      t.integer :status_code
      t.text :violated_directive

      t.timestamps
    end
  end
end
