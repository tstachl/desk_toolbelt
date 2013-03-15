define ['jquery', 'modules/mapping'], ($) ->
  class Migration
    app: null
    
    constructor: ->
      this.messages()
          .accordion()
          .mapping()
    
    messages: ->
      do $('.message').slideDown().delay(5000).slideUp
      @
    
    accordion: ->
      $('.accordion .collapse').on 'hide', ->
        $(@).parents('.accordion-group').find('i').removeClass('icon-chevron-down').addClass('icon-chevron-right')
      $('.accordion .collapse').on 'show', ->
        $(@).parents('.accordion-group').find('i').removeClass('icon-chevron-right').addClass('icon-chevron-down')
      @
    
    mapping: ->
      $('.mapping').mapping()