class Entrance::Application < ActiveRecord::Base
  # TODO XXX
  self.table_name_prefix = 'entrance_'

  belongs_to :campaign, class_name: 'Entrance::Campaign'
  belongs_to :entrant, class_name: 'Entrance::Entrant'
  belongs_to :competitive_group_item, class_name: 'Entrance::CompetitiveGroupItem'
  belongs_to :competitive_group, class_name: 'Entrance::CompetitiveGroup'

  delegate :direction, to: :competitive_group_item

  has_many :benefits, class_name: 'Entrance::Benefit'

  after_create do |application|
    Entrance::Log.create entrant_id: application.entrant.id,
                         user_id: User.current.id,
                         comment: "Создано заявление #{application.id}."
  end

  after_update do |application|
    Entrance::Log.create entrant_id: application.entrant.id,
                         user_id: User.current.id,
                         comment: "Обновлено заявление #{[application.number, application.id].join(', ')}."
  end

  # default_scope do
  #   where('status_id != ?', 6)
  # end

  scope :for_direction, -> (direction) do
    joins(:competitive_group_item).
      where("competitive_group_items.direction_id = #{direction.id}")
  end

  scope :paid, -> do
    where('number_paid_o > 0 OR number_paid_oz > 0 OR number_paid_z > 0').
    where('number_budget_o = 0 AND number_budget_oz = 0 AND number_budget_z = 0').
    where('number_quota_o = 0 AND number_quota_oz = 0 AND number_quota_z = 0')
  end

  scope :not_paid, -> do
    where('number_paid_o = 0 AND number_paid_oz = 0 AND number_paid_z = 0')
  end

  scope :o_form, -> do
    where('number_budget_o > 0 OR number_paid_o > 0 OR number_quota_o > 0')
  end

  scope :oz_form, -> do
    where('number_budget_oz > 0 OR number_paid_oz > 0 OR number_quota_oz > 0')
  end

  scope :z_form, -> do
    where('number_budget_z > 0 OR number_paid_z > 0 OR number_quota_z > 0')
  end

  def self.direction_stats(campaign, direction)
    applications = campaign.applications.for_direction(direction)
    stats = {
      budget: {
        o:  { total: 0, original: 0 },
        oz: { total: 0, original: 0 },
        z:  { total: 0, original: 0 }
      },
      paid: {
        o:  { total: 0, original: 0 },
        oz: { total: 0, original: 0 },
        z:  { total: 0, original: 0 }
      }
    }
    applications.each do |app|
      form = case app.competitive_group_item.form
        when 11
          :o
        when 12
          :oz
        when 10
          :z
      end

      payment_form = app.competitive_group_item.payed? ? :paid : :budget

      stats[payment_form][form][:total] += 1
      stats[payment_form][form][:original] += 1 if app.original?
    end

    stats
  end

  def entrance_type
    if benefits.first && benefits.first.benefit_kind.out_of_competition?
      return benefits.first.benefit_kind.name
    end

    use = true
    entrant.exam_results.in_competitive_group(competitive_group_item.competitive_group).each do |exam_result|
      use = false if exam_result.university?
    end

    use ? 'ЕГЭ' : 'Внутренние испытания'
  end

  def out_of_competition
    if benefits
      benefits.first.benefit_kind.out_of_competition?
    end

    false
  end

  def called_back?
    6 == status_id
  end

  def to_fis
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.Application do
        xml.UID               id
        xml.ApplicationNumber number
        xml.Entrant do
          xml.UID         entrant.id
          xml.FirstName   entrant.first_name
          xml.MiddleName  entrant.patronym
          xml.LastName    entrant.last_name
          xml.GenderID    entrant[:gender]
        end
        xml.RegistrationDate  created_at.iso8601
        xml.NeedHostel        entrant.need_hostel
        xml.StatusID          status_id
        xml.SelectedCompetitiveGroups do
          xml.CompetitiveGroupID competitive_group_item.competitive_group.id
        end
        xml.SelectedCompetitiveGroupItems do
          xml.CompetitiveGroupItemID competitive_group_item_id
        end
        xml.FinSourceAndEduForms do
          xml.FinSourceEduForm do
            xml.FinanceSourceID     (competitive_group_item.payed? ? 15 : 14)
            xml.EducationFormID     competitive_group_item.form
            xml.CompetitiveGroupID  competitive_group_item.competitive_group.id
            xml.CompetitiveGroupItemID  competitive_group_item_id
          end
        end
        xml.ApplicationDocuments do
          xml.IdentityDocument do
            xml.OriginalReceived true
            xml.DocumentSeries  entrant.pseries
            xml.DocumentNumber  entrant.pnumber
            xml.DocumentDate    entrant.pdate.iso8601
            xml.IdentityDocumentTypeID  entrant.identity_document_type_id
            xml.NationalityTypeID       entrant.nationality_type_id
            xml.BirthDate               entrant.birthday.iso8601
          end
          # xml.EduDocuments do
          #   xml.EduDocument do
          #     xml.SchoolCertificateDocument do
          #       xml.OriginalReceived original
          #       xml.DocumentSeries entrant.certificate_series
          #       xml.DocumentNumber entrant.certificate_number
          #
          #     end
          #   end
          # end
        end
      end
    end

    builder.doc
  end
end
