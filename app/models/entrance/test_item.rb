class Entrance::TestItem < ActiveRecord::Base
  # TODO Почему-то не получается перенести table_name_prefix в entrance.rb
  self.table_name_prefix = 'entrance_'

  belongs_to :competitive_group, class_name: 'Entrance::CompetitiveGroup'
  has_many :benefit_items, class_name: 'Entrance::TestBenefitItem',
           foreign_key: :entrance_test_item_id
  accepts_nested_attributes_for :benefit_items
  belongs_to :exam, class_name: 'Entrance::Exam'

  scope :from_direction, -> direction_id { joins(:competitive_group).where('competitive_group_id IN (?)', Entrance::CompetitiveGroupItem.from_direction(direction_id).collect{|x| x.competitive_group_id}.join(','))}
end