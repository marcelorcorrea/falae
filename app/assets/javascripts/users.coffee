# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  userPhotoInput = document.getElementById 'user_photo'
  if userPhotoInput
  # add event listener to load user photo preview on form
    userPhotoInput.addEventListener 'change', (e) ->
      userPhotoContainer = document.getElementById('user-photo-container')
      files = e.target.files
      photo = files[0]
      if photo && /.*\.(jpe?g|png|gif)/i.test photo.name
        reader = new FileReader()
        reader.onload = (file) ->
          img_base64 = new Image()
          img_base64.src = file.target.result
          userPhotoContainer.innerHTML = img_base64.outerHTML
        reader.readAsDataURL photo
      else
        inputFileButton = document.getElementsByClassName('wrapper-custom-input-file')[0]
        unsuportedPhotoTypeText = inputFileButton.dataset.unsupportedPhotoType
        alert unsuportedPhotoTypeText

  editCheckBox = document.getElementById 'edit_sensitive_data'
  if editCheckBox
    editCheckBox.addEventListener 'click', (e) ->
      sensitiveDataElems = document.getElementsByClassName 'sensitive-data'
      for elem in sensitiveDataElems
        input = elem.getElementsByTagName('input')[0]
        if e.target.checked
          elem.style.color = 'inherit'
          input.disabled = false
          input.style.color = '#2E8B57'
        else
          elem.style.color = '#AAAAAA'
          input.disabled = true
          input.style.color = '#AAAAAA'
