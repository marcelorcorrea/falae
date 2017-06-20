# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  pageItemsTab = document.getElementsByClassName('page-items-tab')[0]
  pageMobileTab = document.getElementsByClassName('page-mobile-tab')[0]
  pageItemList = document.getElementsByClassName('page-items-list')[0]
  pageMobileView = document.getElementsByClassName('page-mobile-view')[0]

  if pageItemsTab
    pageItemsTab.addEventListener 'click', () ->
      pageMobileTab.classList.remove 'active'
      pageMobileView.classList.remove 'active'
      pageItemsTab.classList.add 'active'
      pageItemList.classList.add 'active'

  if pageMobileTab
    pageMobileTab.addEventListener 'click', () ->
      pageItemsTab.classList.remove 'active'
      pageItemList.classList.remove 'active'
      pageMobileTab.classList.add 'active'
      pageMobileView.classList.add 'active'

  if pageItemList
    cards = pageItemList.querySelectorAll 'div.card'
    srcEl = null
    for card in cards
      card.addEventListener 'dragstart', (e) ->
        srcEl = this
        this.style.opacity = '0.5'
        e.dataTransfer.effectAllowed = 'move'
        e.dataTransfer.setData 'text/html', this.innerHTML
      card.addEventListener 'dragenter', (e) ->
        this.classList.add 'over'
      card.addEventListener 'dragover', (e) ->
        e.preventDefault
        e.dataTransfer.dropEffect = 'move'
        return false
      card.addEventListener 'dragleave', (e) ->
        this.classList.remove 'over'
      card.addEventListener 'drop', (e) ->
        e.stopPropagation()
        if srcEl != this
          srcEl.innerHTML = this.innerHTML
          this.innerHTML = e.dataTransfer.getData 'text/html'
        this.classList.remove 'over'
        return false
      card.addEventListener 'dragend', (e) ->
        this.style.opacity = '1'
