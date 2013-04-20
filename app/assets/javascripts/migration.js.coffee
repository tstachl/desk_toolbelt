require ['modules/application', 'modules/migration'], (Application, Migration) ->
	Application.getInstance()
	return new Migration()