require 'spec_helper'

describe String do
  it 'verifies a valid json string' do
    '{}'.should be_is_json
  end
  
  it 'returns false for a invalid json string' do
    'Invalid'.should_not be_is_json
  end
end