define ['jquery', 'modules/export', 'bootstrap', 'datepicker'], ($, Export) ->
  class Application
    @click: 'click'
    @instance: null
    
    @getInstance: ->
      Application.instance ?= new Application()
    
    doc: $ document
    constructor: ->
      this.carousel()
          .datepicker()
          .tooltips()
          .events()
          .exports()
    
    events: ->
      @doc.on Application.click, 'a[href="#"]', (e) ->
        e.preventDefault()
      @doc.on Application.click, 'a.disabled', (e) ->
        e.preventDefault()
        no

      @doc.on 'submit', 'form[data-modal="true"]', @modal
      @doc.on Application.click, 'a[data-modal="true"]', @modal
      @doc.on Application.click, 'input[data-reset="true"]', @resetForm
      @
    
    carousel: ->
      $('.carousel').carousel()
      @
    
    datepicker: ->
      $('input.datepicker').datepicker()
      @
  
    tooltips: ->
      $('.controls').has('.help-block').each (index, item) ->
        $item = $ item
        text = $item.find('.help-block').text()

        $item.find('.help-block').remove()
        $item.tooltip
          delay: { show: 500, hide: 100 }
          selector: if $item.find('input').size() > 0 then 'input' else if $item.find('textarea').size() > 0 then 'textarea' else 'select'
          trigger: 'focus'
          title: text
      @
  
    modal: (e) ->
      e.preventDefault()

      $this = $(this)
      method = $this.attr('method') or 'GET'
      button = if $this.hasClass('btn') and $this.data('loadingText') then $this else $this.find('[data-loading-text]')
      button.button 'loading'

      $.ajax $this.attr('href') or $this.attr('action'),
        data: if typeof $this['serialize'] == 'function' then $this.serialize() else ''
        dataType: 'html'
        type: method
        success: (data, textStatus, jqXHR) ->
          button.button 'reset'
          modal = $('body').append(data).find('.modal').last().modal()
    
          modal.on Application.click, '[data-submit="modal"]', (e) ->
            modal.find('form').submit()
          modal.on 'hidden', ->
            modal.remove()
  
    resetForm: (e) ->
      e.preventDefault()
    
      $this = $(this)
      form  = $this.parents 'form'
    
      form.find('input:text, input:password, input:file, select, textarea').val ''
      form.find('input:radio, input:checkbox').removeAttr('checked').removeAttr 'selected'
  
    exports: ->
      $('[data-export]').each (index, item) ->
        new Export $(item).data('export')
      @