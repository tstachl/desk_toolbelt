require 'spec_helper'

describe ApplicationHelper do
  describe '#flash_messages' do
    it 'returns a string if flash messages are set' do
      flash[:info] = 'This is a flash message.'
      helper.flash_messages.should_not be_nil
    end
    
    it 'returns an empty string if no flash messages are set' do
      helper.flash_messages.should be_blank
    end
  end
  
  describe '#migration_flash' do
    it 'returns a string if flash messages are set' do
      flash[:info] = 'This is a flash message.'
      helper.migration_flash.should_not be_nil
    end
    
    it 'returns an empty string if no flash messages are set' do
      helper.migration_flash.should be_blank
    end
  end
end