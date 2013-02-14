FactoryGirl.define do
  factory :auth do
    provider
    uid '21084237'
    token Faker::Lorem.characters
    secret Faker::Lorem.characters
    user
    site
  end
end