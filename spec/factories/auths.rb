FactoryGirl.define do
  factory :auth do
    provider
    uid '21084237'
    token Faker::Lorem.characters
    secret Faker::Lorem.characters
    user
    site
    
    factory :auth_zendesk do
      provider { Provider.find_by_name('zendesk') || FactoryGirl.create(:provider_zendesk) }
    end
  end
end