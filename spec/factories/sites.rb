FactoryGirl.define do
  factory :site do
    name "https://devel.desk.com"
    
    factory :zendesk_site do
      name "https://globalsurfco.zendesk.com"
    end
  end
end