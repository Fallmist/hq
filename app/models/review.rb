class Review < ActiveRecord::Base
  belongs_to :appointment # связь с должностями
  belongs_to :university, foreign_key: :university_id
  belongs_to :university_author, class_name: University, foreign_key: :university_auth_id

  #validates :contract_date, presence: true
  #validates :sheet_number, presence: true

  enum status: {    # статус рецензии
      обработка: 0,
      завершен: 1,
      истек: 2
  }
  enum ordt: {    # тип заказа
      физ: 0,
      юр: 1
  }
  enum evaluation: {    # тип отзыва на рецензию
      '+' => 0,
      '-' => 1,
      неопр: 2
  }
  enum paid: {    # оплата
      да: 0,
      нет: 1
  }
  scope :keyword_search, -> (params) { where("title LIKE ? OR author LIKE ? OR number_review LIKE ? OR contract_number LIKE ? OR total_cost LIKE ? OR cost LIKE ?", "%#{params[:search_keywords]}%", "%#{params[:search_keywords]}%", "%#{params[:search_keywords]}%", "%#{params[:search_keywords]}%", "#{params[:search_keywords]}%", "#{params[:search_keywords]}%") }
  scope :date_search, -> (params) { where(contract_date: Date.parse(params[:start_date])..Date.parse(params[:end_date])) }
  scope :university_search, ->(params) {
    joins('LEFT JOIN universities AS u ON u.id = university_id')
    .joins('LEFT JOIN universities AS u_a ON u_a.id = university_auth_id')
    .where('u.name LIKE ? OR u_a.name LIKE ?', "%#{params[:search_keywords]}%", "%#{params[:search_keywords]}%") }

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |review|
        csv << review.attributes.values_at(*column_names)
      end
    end
  end
end