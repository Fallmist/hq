class Entrance::DocumentType < ActiveRecord::Base
  self.table_name_prefix = 'entrance_'

  has_many :edu_documents, class_name: 'Entrance::EduDocument'
end
