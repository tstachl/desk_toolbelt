= Authorization Flow
This is going to influence the authentication flow as it'll be reusing the from_omniauth methods.

== Authorization
1. The user goes to the user settings
  (a). He clicks on add new site
    1. He enters the sites name
    2. We check if the site exists
      (a). it doesn't exist
        1. We create the new site name
      (b). it does exist
        1. We use the site for further processing
    3. We check if an auth exists for the site and user
      (a). it exists ?? Maybe not
        1. The user gets a notice that the authorization already exists
      (b). it doesn't exist
        1. He gets redirected to desk.com to enter his username and password
        2. He has to approve our application
        3. He gets redirected to our application
        4. We create the Auth
        5. We connect the auth with the user and the site
        6. He gets a notice that the authorization has been created
  (b). He clicks on add zendesk auth
    1. He enters the username, token and site name
    2. We check if the authorization works
      (a). it works
        1. We add the authorization
        2. He gets a notice that the authorization has been created
      (b). it doesn't work
        1. He gets a notice that the authorization didn't work 