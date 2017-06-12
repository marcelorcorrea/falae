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
