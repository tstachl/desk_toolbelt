class @Application.Export
  constructor: (config = {}) ->
    for key, value of config
      @[key] = value
    
    @data_url = "/exports/#{@id}.json"
    @dom_el = $ "#export_#{@id}"
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
    if @is_exported
      do @finish
    else if @is_exporting
      do @progress
    else
      do @queue
  
  step: (step) ->
    @dom_el.find('.wizard-step').removeClass('active')
    @dom_el.find(".wizard-step:nth-child(#{step})").addClass('active')
  
  download: (show = false) ->
    @btnGroup.find('.btn-success').remove()
    if show
      @btnGroup.prepend '<a href="' + @url + '" class="wizard-action btn btn-success btn-large" rel="nofollow"><i class="icon-download icon-white"></i> Download</a>'
  
  delete: (show = false) ->
    @btnGroup.find('.btn-danger').remove()
    if show
      @btnGroup.append '<a href="/exports/' + @id + '" class="wizard-action btn btn-danger btn-large" data-method="delete" rel="nofollow"><i class="icon-remove icon-white"></i> Delete</a>'
  
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