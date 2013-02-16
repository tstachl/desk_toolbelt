define ['jquery', 'modules/application'], ($, Application) ->
  class Migration
    app: null
    
    constructor: ->
      @app = Application.getInstance()
      this.messages()
          .accordion()
    
    messages: ->
      do $('.message').slideDown().delay(5000).slideUp
      @
    
    accordion: ->
      $('.accordion .collapse').on 'hide', ->
        $(@).parents('.accordion-group').find('i').removeClass('icon-chevron-down').addClass('icon-chevron-right')
      $('.accordion .collapse').on 'show', ->
        $(@).parents('.accordion-group').find('i').removeClass('icon-chevron-right').addClass('icon-chevron-down')
      @
      
# 
# # Reference jQuery
# $ = jQuery
# 
# $.fn.extend
#   mapping: (options) ->
#     @el   = $(this)
#     @from = @el.find('.from')
#     @to   = @el.find('.to')
#     
#     for key, value of @from.data 'mapping' 
#       @from.append [
#         '<li class="mapitem">'
#           key
#         '</li>'
#       ].join ''
#     
#     for key, value of @to.data 'mapping'
#       @to.append [
#         '<li class="mapitem">'
#           key
#         '</li>'
#       ].join ''
#     
#     return @each ()->