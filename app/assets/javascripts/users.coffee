# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  userPhotoInput = document.getElementById 'user_photo'
  if userPhotoInput
  # add event listener to load user photo preview on form
    userPhotoInput.addEventListener 'change', (e) ->
      files = e.target.files
      photo = files[0]
      if photo && /.*\.(jpe?g|png|gif)/i.test photo.name
        reader = new FileReader()
        reader.readAsDataURL photo
        reader.onload = (file) -> loadPreview(file)
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

  loadPreview = (file) ->
    imgBase64 = new Image()
    imgBase64.src = file.target.result
    originalImgWidth = 0
    originalImgHeight = 0
    initialXPos = 0
    initialYPos = 0
    selectionWidth = 150
    selectionHeight = 180
    overlay = $('.overlay').get(0)
    $(overlay).css 'display', 'block'
    $('.img-crop-container').html imgBase64.outerHTML

    updateCrop = (coords) ->
      $('#crop_x').val coords.x
      $('#crop_y').val coords.y
      $('#crop_w').val coords.w
      $('#crop_h').val coords.h

    resetCrop = (coords) ->
      $('#crop_x').val ''
      $('#crop_y').val ''
      $('#crop_w').val ''
      $('#crop_h').val ''

    imgBase64.onload = () ->
      originalImgWidth = imgBase64.width
      originalImgHeight = imgBase64.height
      initialXPos = Math.max 0, originalImgWidth/2 - selectionWidth/2
      initialYPos = Math.max 0, originalImgHeight/2 - selectionHeight/2
      $('.img-crop-container img').Jcrop {
        allowSelect: false,
        aspectRatio: selectionWidth / selectionHeight,
        boxWidth: 760,
        minSize: [selectionWidth, selectionHeight],
        setSelect: [
          initialXPos,
          initialYPos,
          initialXPos + selectionWidth,
          initialYPos + selectionHeight
        ],
        onChange: updateCrop,
        onSelect: updateCrop,
      }

    updatePhotoPreview = (ev) ->
      cropW = $('#crop_w').val()
      cropH = $('#crop_h').val()
      cropX = $('#crop_x').val()
      cropY = $('#crop_y').val()
      imgBase64.width = selectionWidth * originalImgWidth / cropW
      imgBase64.height = selectionHeight * originalImgHeight / cropH
      rx = selectionWidth / cropW
      ry = selectionHeight / cropH
      $('#user-photo-wrapper').html imgBase64.outerHTML
      $('#user-photo-wrapper img').css {
        marginLeft: '-' + Math.round(rx * cropX) + 'px',
        marginTop: '-' + Math.round(ry * cropY) + 'px',
      }
      closeDialog(ev)

    closeDialog = (event) ->
      event.preventDefault() if event
      $(overlay).css 'display', 'none'
      $('body').css 'overflow', 'initial'
      $(document).off 'keyup', closeDialogOnEscape

    closeDialogOnClick = (ev) ->
      resetCrop()
      closeDialog ev

    closeDialogOnEscape = (ev) ->
      if ev.which == 27 # ESC
        closeDialogOnClick ev
      else if ev.which == 13 # ENTER
        updatePhotoPreview ev


    $(document).on 'click', '#crop-btn', updatePhotoPreview
    $('.close').on 'click', closeDialog
    $(document).on 'keyup', closeDialogOnEscape
