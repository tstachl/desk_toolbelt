FactoryGirl.define do
  factory :provider do
    name 'desk'
    type 'Provider::Desk'

    factory :provider_zendesk do
      name 'zendesk'
      type 'Provider::Zendesk'
    end
  end
end