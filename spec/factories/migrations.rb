FactoryGirl.define do
  factory :migration do
    association :to, factory: :auth
    association :from, factory: :auth_zendesk
    
    articles true
    cases true
    customers true
    interactions true
    topics true
  end
end