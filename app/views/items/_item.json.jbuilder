json.extract! item, :name, :speech, :link_to

json.category item.category.base_name
json.img_src item.image.image
json.private item.image.private?
