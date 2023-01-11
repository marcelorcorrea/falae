# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  # delete multiple items
  $('.item-checkbox > .checkbox').click ->
    $(this).removeClass 'show'
    $(this).siblings().addClass 'show'
    layer = $(this).parent().siblings('.layer')
    layer.addClass 'selected'
    deleteBtn = $('#items-page-delete-button')
    deleteBtn.removeClass 'disabled'
    hrefSplited = deleteBtn.attr('href').split('=')
    curIds = if hrefSplited[1] then hrefSplited[1].split(',') else []
    curIds.push($(this).parent().parent().data('item-id'))
    deleteBtn.attr('href', hrefSplited[0] + '=' + curIds.join(','))

    that = $(this)
    layer.click ->
      $(this).removeClass 'selected'
      if !$(this).parent().siblings('.wrapper').children('.layer.selected').length
        $('#items-page-delete-button').addClass 'disabled'
      $(this).siblings('.item-checkbox').toggleClass 'show'
      that.addClass 'show'
      that.siblings().removeClass 'show'
      itemId = $(this).parent().data('item-id')
      layerCurIds = deleteBtn.attr('href').split('=')[1].split(',')
      filtered = layerCurIds.filter((id) -> id != itemId + '')
      deleteBtn.attr('href', hrefSplited[0] + '=' + filtered.join(','))
      $(this).off 'click'
  #

  $('#item-image').parent().css { display: 'inline-block' }

  itemImageInput = document.getElementById 'item_image_attributes_image'
  if itemImageInput
  # add event listener to load item image preview on form
    itemImageInput.addEventListener 'change', (e) ->
      files = e.target.files
      image = files[0]
      if image && /.*\.(jpe?g|png|gif)/i.test image.name
        reader = new FileReader()
        reader.readAsDataURL image
        reader.onload = (file) -> loadPreview(file)
      else
        inputFileButton = document.getElementsByClassName('wrapper-custom-input-file')[0]
        unsuportedImageTypeText = inputFileButton.dataset.unsupportedImageType
        alert unsuportedImageTypeText

  loadPreview = (file) ->
    imgBase64 = new Image()
    imgBase64.src = file.target.result
    originalImgWidth = 0
    originalImgHeight = 0
    initialXPos = 0
    initialYPos = 0
    selectionWidth = 150
    selectionHeight = 150
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
      $('#item-image-wrapper').html imgBase64.outerHTML
      $('#item-image-wrapper').css { display: 'inline-block' }
      $('#item-image-wrapper img').css {
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
