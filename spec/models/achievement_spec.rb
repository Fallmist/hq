require 'spec_helper'
describe Achievement do
  describe 'обладает связями с другими моделями:' do
    it 'с периодом' do
      should belong_to(:period)
    end
    it 'с человеком' do
      should belong_to(:user)
    end
    it 'с деятельностью' do
      should belong_to(:activity)
    end
  end
end

