require 'spec_helper'

describe ActivityCreditType do
  describe 'обладает связями с другими моделями' do
    it 'с деятельностью' do
      should have_many(:activities)
    end
  end
end
