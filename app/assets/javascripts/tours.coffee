document.addEventListener 'turbolinks:load', ->
  if RegExp('create-item-tour&step-2', 'gi').test window.location.search
    userItemsCreateButton = document.querySelector '.button-box[data-id=create-item-tour]'
    href = userItemsCreateButton.getAttribute 'href'
    userItemsCreateButton.setAttribute 'href', href + '/?create-item-tour&step-3'
    intro = introJs()
    options = {
      doneLabel: 'Próximo',
      showBullets: false,
      showStepNumbers: false
    }
    intro.setOptions options
    intro.goToStepNumber(2).start()
      .oncomplete () ->
        window.location.href = '/users/1/items/new?create-item-tour&step-3'
  else if RegExp('create-item-tour&step-3', 'gi').test window.location.search
    intro = introJs()
    options = {
      doneLabel: 'Próximo',
      showBullets: false,
      showStepNumbers: false
    }
    intro.setOptions options
    intro.goToStepNumber(3).start()
      .oncomplete () ->
        window.location.href = '/users/1/items/new'
  else
    createItemTour = document.getElementById 'create-item-tour'
    if createItemTour
      createItemTour.addEventListener 'click', () ->
        userItems = document.querySelector '.menu-item[data-id=create-item-tour]'
        # userItemsLink = userItems.getElementsByTagName('a')[0]
        # href = userItemsLink.getAttribute 'href'
        # userItemsLink.setAttribute 'href', href + '/?create-item-tour&step-2'

        intro = introJs()
        options = {
          doneLabel: userItems.dataset.doneLabel,
          showBullets: false,
          showStepNumbers: false
        }
        intro.setOptions options
        intro.start()
          .oncomplete () ->
            window.location.href = '/users/1/items?create-item-tour&step-2'
