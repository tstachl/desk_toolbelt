FactoryGirl.define do
  factory :user do
    name Faker::Name.name
    email { |u| Faker::Internet.email(u.name) }
    role
  end
end