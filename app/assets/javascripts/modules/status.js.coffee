define ['jquery'], ($) ->
  class StatusUpdater
    constructor: (@dom_el, config = {}) ->
      for key, value of config
        @[key] = value
      @data_url = "/#{@type}/#{@id}.json"
      @btnGroup = @dom_el.find '.wizard-actions'
      @counter = 0

      do @process
    
    fetch: ->
      setTimeout(=>
        $.getJSON @data_url, (data) =>
          @counter++
          for key, value of data
            @[key] = value
          do @process
      if @counter == 0 then 200 else 2000)
    
    process: ->
      if @is_exported or @is_imported
        do @finish
      else if @is_exporting or @is_importing
        do @progress
      else
        do @queue

    step: (step) ->
      @dom_el.find('.wizard-step').removeClass('active')
      @dom_el.find(".wizard-step:nth-child(#{step})").addClass('active')

    download: (enabled = false) ->
      if enabled
        @btnGroup.find('.btn-success').removeClass('disabled').attr('href', @url)
      else
        @btnGroup.find('.btn-success').addClass('disabled').attr('href', '#')

    delete: (enabled = false) ->
      if enabled
        @btnGroup.find('.btn-danger').removeClass('disabled')
      else
        @btnGroup.find('.btn-danger').addClass('disabled')

    finish: ->
      @step 3
      @download true
      @delete true

    progress: ->
      @step 2
      @download false
      @delete false
      do @fetch

    queue: ->
      @step 1
      @download false
      @delete true
      do @fetch
