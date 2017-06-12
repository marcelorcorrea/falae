# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  userItemsTab = document.getElementsByClassName('user-items-tab')[0]
  searchItemsTab = document.getElementsByClassName('search-items-tab')[0]
  userItemList = document.getElementsByClassName('user-items-list')[0]
  searchItemsList = document.getElementsByClassName('search-items-list')[0]

  if userItemsTab
    userItemsTab.addEventListener 'click', () ->
      searchItemsTab.classList.remove 'active'
      searchItemsList.classList.remove 'active'
      userItemsTab.classList.add 'active'
      userItemList.classList.add 'active'

  if searchItemsTab
    searchItemsTab.addEventListener 'click', () ->
      userItemsTab.classList.remove 'active'
      userItemList.classList.remove 'active'
      searchItemsTab.classList.add 'active'
      searchItemsList.classList.add 'active'
