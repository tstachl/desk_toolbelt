FactoryGirl.define do
  factory :user do
    name Faker::Name.name
    email { |u| Faker::Internet.email(u.name) }
    role { Role.find_by_name('siteadmin_billing') || FactoryGirl.create(:role) }
  end
end