# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  itemImageInput = document.getElementById 'item_image'
  if itemImageInput
  # add event listener to load user photo preview on form
    itemImageInput.addEventListener 'change', (e) ->
      files = event.target.files
      image = files[0]
      reader = new FileReader()
      reader.onload = (file) ->
        img_base64 = new Image()
        img_base64.src = file.target.result
        itemImageContainer = document.getElementById('item-image-container')
        itemImageContainer.innerHTML = img_base64.outerHTML
      reader.readAsDataURL image
