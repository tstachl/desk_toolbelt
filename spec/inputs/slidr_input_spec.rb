# spec/inputs/slidr_input_spec.rb
require 'spec_helper'

describe 'slidr input' do
  context 'nested_boolean_style?' do
    before do
      concat input_for(:foo, :customers, as: :slidr)
    end

    it 'creates a checkbox element' do
      assert_select 'input[type=checkbox]', count: 1
    end
  
    it 'creates a span element' do
      assert_select 'span', count: 1
    end
  end
  
  context 'not nested_boolean_style?' do
    before do
      concat input_for(:foo, :customers, as: :slidr, boolean_style: :not_nested)
    end

    it 'creates a checkbox element' do
      assert_select 'input[type=checkbox]', count: 1
    end

    it 'creates a span element' do
      assert_select 'span', count: 1
    end
  end

  context 'label nested_boolean_style?' do
    before do
      concat label_input_for(:foo, :customers, as: :slidr)
    end

    it 'creates a checkbox element' do
      assert_select 'input[type=checkbox]', count: 1
    end

    it 'creates a span element' do
      assert_select 'span', count: 1
    end
  end

  context 'label not nested_boolean_style?' do
    before do
      concat label_input_for(:foo, :customers, as: :slidr, boolean_style: :not_nested)
    end

    it 'creates a checkbox element' do
      assert_select 'input[type=checkbox]', count: 1
    end

    it 'creates a span element' do
      assert_select 'span', count: 1
    end
  end

  context 'no label' do
    before do
      concat label_input_for(:foo, :customers, as: :slidr, label: false)
    end

    it 'creates a checkbox element' do
      assert_select 'input[type=checkbox]', count: 1
    end

    it 'creates a span element' do
      assert_select 'span', count: 1
    end
  end
end