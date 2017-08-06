# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  userPhotoInput = document.getElementById 'user_photo'
  if userPhotoInput
  # add event listener to load user photo preview on form
    userPhotoInput.addEventListener 'change', (e) ->
      files = event.target.files
      image = files[0]
      reader = new FileReader()
      reader.onload = (file) ->
        img_base64 = new Image()
        img_base64.src = file.target.result
        userPhotoContainer = document.getElementById('user-photo-container')
        userPhotoContainer.innerHTML = img_base64.outerHTML
      reader.readAsDataURL image
