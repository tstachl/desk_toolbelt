define ['jquery', 'plumb', 'jqueryui', 'touch'], ($, jsPlumb) ->
  
  document.onselectstart = -> return no
  
  render_mode = jsPlumb.CANVAS
  render_mode = jsPlumb.VML if jsPlumb.isVMLAvailable()
  render_mode = jsPlumb.SVG if jsPlumb.isSVGAvailable()
  render_mode = jsPlumb.setRenderMode render_mode
  
  
  class Mapping
    el: null
    from: null
    to: null
    
    connections: []
    
    constructor: (el, options) ->
      @el   = $ el
      @from = @el.find '.from'
      @to   = @el.find '.to'
      
      jsPlumb.importDefaults
        Endpoint: ['Dot', { radius: 2 }]
        ConnectorZIndex: 100
        HoverPaintStyle: 
          strokeStyle: "#ec9f2e"
      
      jsPlumb.draggable(jsPlumb.getSelector(".mapitem"));
      jsPlumb.bind 'click', (info, ev) ->
        jsPlumb.detach info
      jsPlumb.bind 'connection', (info, ev) =>
        @update_connections info.connection
      jsPlumb.bind 'connectionDetached', (info, ev) =>
        @update_connections info.connection, yes
      
      @render @from, @from.data 'mapping'
      @render @to, @to.data 'mapping'
      
      @from.find('.mapitem').each (index, item) =>
        jsPlumb.makeSource item,
          anchor: 'RightMiddle'
          connector: 'Bezier'
          connectorStyle:
            strokeStyle: '#674397'
            lineWidth: 2
          maxConnections: 1
          deleteEndpointsOnDetach: yes
          scope: "#{@from.data('type')}"
          onMaxConnections: @max_connections

      @to.find('.mapitem').each (index, item) =>
        jsPlumb.makeTarget item,
          dropOptions:
            hoverClass: 'success'
            activeClass: 'active'
          anchor: 'LeftMiddle'
          maxConnections: 1
          deleteEndpointsOnDetach: yes
          scope: "#{@to.data('type')}"
          onMaxConnections: @max_connections
    
    render: (el, data) ->
      if $.type(data) == 'array'
        for item in data
          child = @render_item el, item.name, item.type
      else
        for key, value of data
          child = @render_item el, key, $.type value
          if $.type(value) == 'object'
            @render $('<ul>').appendTo(child), value
          else if key == 'custom_fields'
            @render $('<ul>').appendTo(child), value
      
    render_item: (list, item, type) ->
      el = $([
        '<li class="mapitem" data-type="' + type + '">'
          '<span>'
            item
            '<small>&nbsp;'
              type
            '</small>'
          '</span>'
        '</li>'
      ].join('')).appendTo list
      el
    
    update_connections: (conn, remove) ->
      unless remove
        conn.source.addClass 'connected'
        conn.target.addClass 'connected'
        @connections.push conn
      else
        idx = -1
        for connection, index in @connections
          if connection == conn
            conn.source.removeClass 'connected'
            conn.target.removeClass 'connected'
            idx = index
            break
        @connections.splice idx, 1 unless idx == -1
    
    max_connections: (info) ->
      alert "Only one connection is allowed at a time."
  
  $.fn.extend
    mapping: (options, args...) ->
      return @each ->
        $this = $ this
        
        unless data
          $this.data 'mapping', (data = new Mapping(this, options))
        
        data[options].apply data, args if typeof options == 'string'