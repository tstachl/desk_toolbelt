# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.message').slideDown().delay(5000).slideUp()
  $('.accordion .collapse').on 'hide', ->
    $(@).parents('.accordion-group').find('i').removeClass('icon-chevron-down').addClass('icon-chevron-right')
  $('.accordion .collapse').on 'show', ->
    $(@).parents('.accordion-group').find('i').removeClass('icon-chevron-right').addClass('icon-chevron-down')
  return