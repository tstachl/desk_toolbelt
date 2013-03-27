FactoryGirl.define do
  factory :provider, class: Provider::Desk do
    name 'desk'
    type 'Provider::Desk'

    factory :provider_zendesk, class: Provider::Zendesk do
      name 'zendesk'
      type 'Provider::Zendesk'
    end
  end
end