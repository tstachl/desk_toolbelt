omniauth_name = Faker::Name.name
omniauth_email = Faker::Internet.email(omniauth_name)

OmniAuth.config.mock_auth[:desk] = OmniAuth::AuthHash.new({
  provider:  'desk',
  uid:       '1234565',
  info: {
    name:         omniauth_name,
    name_public:  omniauth_name,
    email:        omniauth_email,
    user_level:   'siteadmin_billing',
    login_count:  55,
    time_zone:    '',
    site:         'https://devel.desk.com'
  },
  credentials: {
    token:        Faker::Lorem.characters,
    secret:       Faker::Lorem.characters
  }
})

OmniAuth.config.mock_auth[:desk_dan] = OmniAuth::AuthHash.new({
  provider:  'desk',
  uid:       '1324565',
  info: {
    name:         omniauth_name,
    name_public:  omniauth_name,
    email:        omniauth_email,
    user_level:   'siteadmin_billing',
    login_count:  55,
    time_zone:    '',
    site:         'https://zzz-dan.desk.com'
  },
  credentials: {
    token:        Faker::Lorem.characters,
    secret:       Faker::Lorem.characters
  }
})

OmniAuth.config.mock_auth[:zendesk] = OmniAuth::AuthHash.new({
  provider: 'zendesk',
  uid:      '1234565',
  credentials: {
    token:        Faker::Lorem.characters,
    secret:       Faker::Lorem.characters
  }
})