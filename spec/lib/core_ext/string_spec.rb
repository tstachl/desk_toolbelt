require 'spec_helper'

describe String do
  it 'verifies a valid json string' do
    '{}'.should be_json
  end

  it 'returns false for a invalid json string' do
    'Invalid'.should_not be_json
  end
  
  it 'verifies a valid xml string' do
    '<cases><case></case></cases>'.should be_xml
  end
  
  it 'returns false for a invalid xml string' do
    'Invalid'.should_not be_xml
  end

  it 'verifies a valid csv string' do
    'CSV,data,String'.should be_csv
  end

  it 'returns false for a invalid csv string' do
    '"Invalid "csv""'.should_not be_csv
  end
end