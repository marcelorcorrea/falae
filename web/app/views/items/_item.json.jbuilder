json.extract! item, :id, :name, :img_src, :speech, :category_id, :created_at, :updated_at
json.url item_url(item, format: :json)
