FactoryGirl.define do
  factory :auth do
    provider
    uid '21084237'
    token Faker::Lorem.characters
    secret Faker::Lorem.characters
    user
    site
    
    factory :zendesk_auth do
      provider 'zendesk'
      uid 'https://my.zendesk.com/api/v2/users/35436.json'
      token Faker::Internet.email
      secret Faker::Lorem.characters
      association :site, factory: :zendesk_site
    end
  end
end