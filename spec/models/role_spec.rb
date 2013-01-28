require 'spec_helper'

describe Role do
  context 'has to be valid and' do
    before do
      @role = Role.new
      @present = Role.create(:name => Faker::Lorem.word)
    end
    
    it 'validates the name is present' do
      is_valid(@role, :name, Faker::Lorem.word)
    end
    
    it 'validates the name is unique' do
      is_valid(@role, :name, @present.name, Faker::Lorem.word)
    end
  end
end
