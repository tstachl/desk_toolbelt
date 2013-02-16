require
  paths:
    jquery: [
      '//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min'
      'libs/jquery'
    ]
    jqueryui: [
      '//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.0/jquery-ui.min'
      'libs/jqueryui'
    ]
    bootstrap: [
      '//cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.0/js/bootstrap.min'
      'libs/bootstrap'
    ]
    datepicker: [
      '//cdnjs.cloudflare.com/ajax/libs/bootstrap-datepicker/1.0.0/js/bootstrap-datepicker.min'
      'libs/bootstrap-datepicker'
    ]
    plumb: [
      'libs/jsplumb'
    ]
    app: ['modules/app']
  shim:
    jquery: 
      exports: 'jQuery'
    jqueryui: ['jquery']
    bootstrap: ['jquery']
    datepicker: ['jquery']
    plumb: ['jquery']
, ['modules/migration'], (Migration) ->
  new Migration()