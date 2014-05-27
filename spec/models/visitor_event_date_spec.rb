require 'spec_helper'

describe VisitorEventDate do 
  # Нужен visitor_event_date.rb в ./factories
  
  # it 'должен обладать валидной фабрикой' do
  #   build(:visitors_count).should be_valid    
  # end

  describe 'обладает связями с другими моделями' do
    it 'с датой' do
      should belong_to(:date)
    end

    it 'с посетителем (polymorphic)' do
      should belong_to(:visitor)
    end

    it 'с пользователем' do
      should belong_to(:user)
    end

    it 'со студентом' do
      should belong_to(:student)
    end
  end
end
