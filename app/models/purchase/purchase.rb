class Purchase::Purchase < ActiveRecord::Base
  has_many :purchase_line_items, class_name: 'Purchase::LineItem', foreign_key: :purchase_id, dependent: :destroy
  belongs_to :department, foreign_key: :dep_id
  validates :dep_id, presence: { message: 'Поле не может быть пустым!'}
  validates :note, length: { minimum: 4, message: 'Введите должность!' }
  validates_associated :purchase_line_items

  accepts_nested_attributes_for :purchase_line_items, allow_destroy: 'true'

  enum status: {обработка: 0, подпись: 1, зарегистрирован: 2}

  scope :statistic, -> (purch) {
    joins('LEFT JOIN purchase_line_items AS li ON li.purchase_id = id')
      .joins('LEFT JOIN purchase_goods AS g ON li.good_id = g.id')
      .where(:id => purch)
  }

end
