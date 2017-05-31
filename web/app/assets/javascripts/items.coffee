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


#  searchResultDiv = document.getElementsByClassName('search-results')[0]

#  list.forEach (result) ->
#    itemResult = document.createElement 'div'
#    itemResult.className = 'item-result'
#
#    img = document.createElement 'img'
#    img.className = 'item-result-img'
#    img.setAttribute 'src', result.img_src
#
#    name = document.createElement 'p'
#    name.className = 'item-result-text'
#    name.innerHTML = '<strong>Name:</strong>' + result.name
#
#    speech = document.createElement 'p'
#    speech.className = 'item-result-text'
#    speech.innerHTML = '<strong>Speech:</strong>' + result.speech
#
#    img_src = document.createElement 'p'
#    img_src.className = 'item-result-text'
#    img_src.innerHTML = '<strong>Image Source:</strong>' + result.img_src
#
#    ctgy = document.createElement 'p'
#    ctgy.className = 'item-result-text'
#    ctgy.innerHTML = '<strong>Category:</strong>' + result.category.name
#
#    searchResultDiv.append itemResult
