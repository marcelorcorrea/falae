# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  # pageItemsTab = document.getElementsByClassName('page-items-tab')[0]
  # pageMobileTab = document.getElementsByClassName('page-mobile-tab')[0]
  pageItemList = document.getElementsByClassName('page-items-list')[0]
  # pageMobileView = document.getElementsByClassName('page-mobile-view')[0]

  # if pageItemsTab
  #   pageItemsTab.addEventListener 'click', () ->
  #     pageMobileTab.classList.remove 'active'
  #     pageMobileView.classList.remove 'active'
  #     pageItemsTab.classList.add 'active'
  #     pageItemList.classList.add 'active'

  # if pageMobileTab
  #   pageMobileTab.addEventListener 'click', () ->
  #     pageItemsTab.classList.remove 'active'
  #     pageItemList.classList.remove 'active'
  #     pageMobileTab.classList.add 'active'
  #     pageMobileView.classList.add 'active'

  addDragAndDropEventListeners = () ->
    cards = pageItemList.querySelectorAll 'div.card'
    srcEl = null
    for card in cards
      card.addEventListener 'dragstart', (e) ->
        srcEl = this
        this.style.opacity = '0.5'
        e.dataTransfer.effectAllowed = 'move'
        e.dataTransfer.setData 'text/html', this.innerHTML
        buttons = this.parentElement.getElementsByTagName 'button'
        for button in buttons
          button.style.display = 'none'
      card.addEventListener 'dragenter', (e) ->
        if srcEl != this
          this.classList.add 'over'
      card.addEventListener 'dragover', (e) ->
        if srcEl != this
          e.preventDefault()
          e.dataTransfer.dropEffect = 'move'
        return false
      card.addEventListener 'dragleave', (e) ->
        this.classList.remove 'over'
      card.addEventListener 'drop', (e) ->
        e.stopPropagation()
        if srcEl != this
          $.ajax {
            type: "PUT",
            url: window.location.href + '/swap_items',
            data: { id_1: srcEl.id, id_2: this.id },
            beforeSend: addLoadingLayer,
            success: removeLoadingLayer
          }
        return false
      card.addEventListener 'dragend', (e) ->
        this.style.opacity = '1'
        buttons = srcEl.parentElement.getElementsByTagName 'button'
        for button in buttons
          button.style.display = ''

  if pageItemList
    addDragAndDropEventListeners()
    observer = new MutationObserver (mutations) ->
      mutations.forEach (mutation) ->
        if mutation.addedNodes.length > 0
          addDragAndDropEventListeners()
    observer.observe pageItemList, {childList: true}

  addLoadingLayer = () ->
    spinner = document.createElement 'div'
    spinner.className = 'fa fa-spinner fa-pulse fa-3x fa-fw'
    loadingLayer = document.createElement 'div'
    loadingLayer.id = 'loading-layer'
    loadingLayer.appendChild spinner
    document.body.appendChild loadingLayer

  removeLoadingLayer = () ->
    loadingLayer = document.getElementById 'loading-layer'
    if loadingLayer
      document.body.removeChild loadingLayer

