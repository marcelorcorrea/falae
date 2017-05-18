json.extract! page, :name, :columns, :rows

json.items page.items do |item|
  json.partial! 'items/item', item: item
end
