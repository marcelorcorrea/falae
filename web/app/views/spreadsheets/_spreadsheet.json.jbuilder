json.extract! spreadsheet, :id, :name, :initial_page, :user_id, :created_at, :updated_at
json.url spreadsheet_url(spreadsheet, format: :json)
