# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  # pageItemsTab = document.getElementsByClassName('page-items-tab')[0]
  # pageMobileTab = document.getElementsByClassName('page-mobile-tab')[0]
  pageItemList = document.getElementsByClassName('page-items')[0]
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
    items = pageItemList.querySelectorAll '.items-list-item:not(.add-button)'
    srcElement = null
    for item in items
      item.addEventListener 'dragstart', (e) ->
        srcElement = this
        this.style.opacity = '0.5'
        e.dataTransfer.effectAllowed = 'move'
        e.dataTransfer.setData 'text/html', this.innerHTML
        itemMenu = this.getElementsByClassName('items-list-item-menu')[0]
        itemMenu.style.display = 'none'
      item.addEventListener 'dragenter', (e) ->
        if srcElement != this
          this.classList.add 'over'
      item.addEventListener 'dragover', (e) ->
        if srcElement != this
          e.preventDefault()
          e.dataTransfer.dropEffect = 'move'
        return false
      item.addEventListener 'dragleave', (e) ->
        this.classList.remove 'over'
      item.addEventListener 'drop', (e) ->
        e.stopPropagation()
        if srcElement != this
          $.ajax {
            type: "PUT",
            url: window.location.href + '/swap_items',
            data: {
              id_1: srcElement.dataset.id,
              id_2: this.dataset.id
            },
            beforeSend: addLoadingLayer,
            success: removeLoadingLayer
          }
        return false
      item.addEventListener 'dragend', (e) ->
        this.style.opacity = '1'
        itemMenu = this.getElementsByClassName('items-list-item-menu')[0]
        itemMenu.style.display = ''

  if pageItemList
    addDragAndDropEventListeners()
    observer = new MutationObserver (mutations) ->
      mutations.forEach (mutation) ->
        if mutation.addedNodes.length > 0
          addDragAndDropEventListeners()
    observer.observe pageItemList, { childList: true }

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
