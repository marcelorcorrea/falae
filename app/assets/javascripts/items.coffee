# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  itemImageInput = document.getElementById 'item_image_attributes_image'
  if itemImageInput
  # add event listener to load item image preview on form
    itemImageInput.addEventListener 'change', (e) ->
      itemImageContainer = document.getElementById('item-image-container')
      files = e.target.files
      image = files[0]
      if image && /.*\.(jpe?g|png|gif)/i.test image.name
        reader = new FileReader()
        reader.onload = (file) ->
          img_base64 = new Image()
          img_base64.src = file.target.result
          itemImageContainer.innerHTML = img_base64.outerHTML
        reader.readAsDataURL image
      else
        inputFileButton = document.getElementsByClassName('wrapper-custom-input-file')[0]
        unsuportedImageTypeText = inputFileButton.dataset.unsupportedImageType
        alert unsuportedImageTypeText
