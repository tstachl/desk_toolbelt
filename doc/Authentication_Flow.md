= Authentication Flow
The authentication is designed to allow a user to manage multiple sites. That entails we have to keep the site context and may allow the user to switch between the different sites. One user can never work on two sites at the same time.

Additionally we have to prepare for other authorizations like Zendesk. In this case the authorization doesn't have a site as context and all additional authorizations are valid in any site context.

== The tables
users
- id
- name
- email (index we connect users by email)
- role_id
sites
- id
- name
auths
- id
- provider (index we look up auths with provider and uid)
- uid (index see above)
- token
- secret
- user_id (index)
- site_id (index)
users_sites
- user_id
- site_id
roles
  - name

== Login/Signup (initial authorization)
1. The user goes to the login page and enters the name of context site
2. He gets redirected to desk.com to enter his username and password
3. He has to approve our application
4. Once he is back and we have the auth hash we can check if this auth already exists
  (a). it exists
    1. we update the auth
    2. we update the user
    3. he gets redirected to the dashbaord
  (b). it doesn't exist
    1. we check if the user exists
      (a). he exists
        1. we update the user
      (b). he doesn't exist
        1. we create a new user
    2. we check if the site exists
      (a). it exists
        1. we check if the user and the site are connected
        (a). connected
          1. moving on
        (b). not connected
          1. we connect the user with the site
      (b). it doesn't exist
        1. we create the site
        2. we connect the user with the site
    3. we create the auth
    4. we connect the auth with the user and the site
    5. he gets redirected to the dashbard