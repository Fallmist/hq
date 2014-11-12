prawn_document margin: [28.34645669291339, 28.34645669291339,
                        28.34645669291339, 56.692913386],
               filename: "Справки-вызов для #{@group.name}.pdf",
               page_size: 'A4', page_layout: :portrait do |pdf|
  render 'pdf/font', pdf: pdf

  @group.students.valid_for_today.each_with_index do |student, index|
    pdf.start_new_page if index > 0
    pdf.move_down 15
    pdf.bounding_box [pdf.bounds.right - 250, pdf.bounds.top - 50], width: 250 do
      pdf.font_size 8 do
        pdf.text 'УТВЕРЖДЕНА', align: :center
        pdf.text 'приказом Министерства образования и науки Российской', align: :center
        pdf.text 'Федерации', align: :center
        pdf.text '19 декабря 2013 г. № 1368', align: :center
      end
    end

    pdf.move_down 30

    pdf.font_size 12 do
      pdf.text 'СПРАВКА-ВЫЗОВ', align: :center, style: :bold
      pdf.text 'от «____» ___________________ 20_______ г.  № __________,', align: :center, style: :bold
      pdf.text 'дающая право на предоставление гарантий и компенсаций работникам, совмещающим работу с получением образования', align: :center, style: :bold
    end

    pdf.font_size 11 do
      pdf.move_down 20
      pdf.text 'Работодателю _______________________________________________________________________________________________'
      pdf.font_size 8 do
        pdf.indent 50 do
          pdf.text 'полное наименование организации-работодателя/фамилия, имя, отчество', align: :center
        end
      end
      pdf.text '________________________________________________________________________________________________________________'
      pdf.font_size 8 do
        pdf.indent 50 do
          pdf.text 'работодателя – физического лица', align: :center
        end
      end
      pdf.text "В соответствии со статьей 173 Трудового кодекса Российской Федерации #{student.person.full_name(:dp)}, обучающе#{student.person.male? ? 'муся' : 'йся'} по #{study_form_name(@group.form, :rp)} форме обучения на #{@group.course} курсе, предоставляются гарантии и компенсации для #{@typecall} с #{l @from} по #{l @to} продолжительностью #{pluralize(@days, 'календарного дня', 'календарных дней', 'календарных дней')}.", align: :justify
      pdf.text "ФГБОУ ВПО «Московский государственный университет печати имени Ивана Федорова» имеет свидетельство о государственной аккредитации, выданное Федеральной службой по надзору в сфере образования и науки 11 августа 2011 г., серия ААА № 001773 (срок действия — бессрочно) по образовательной программе высшего образования по #{@group.speciality.specialist? ? 'специальности' : 'направлению подготовки'} #{@group.speciality.full_name}.", align: :justify
      pdf.move_down 25

      pdf.table [['Ректор МГУП имени Ивана Федорова', '________________________  Антипов К. В.']], width: pdf.bounds.width, cell_style: { padding: 7, border_color: 'ffffff' } do
        column(1).style align: :right
      end
      pdf.font_size 8 do
        pdf.indent 300 do
          pdf.text 'М. П.'
        end
      end
    end

    pdf.move_down 20

    pdf.stroke do
      pdf.move_down 4
      pdf.horizontal_rule
    end
    pdf.font_size 8 do
      pdf.text 'Линия отрыва', align: :center
    end

    pdf.move_down 20
    pdf.font_size 11 do
      pdf.text "#{student.full_name} находил#{student.person.male? ? 'ся' : 'ась'} в ФГБОУ ВПО «Московский государственный университет печати имени Ивана Федорова» с #{l @from} по #{l @to}.", align: :justify
      pdf.move_down 25
      pdf.table [['Ректор МГУП имени Ивана Федорова', '________________________  Антипов К. В.']], width: pdf.bounds.width, cell_style: { padding: 7, border_color: 'ffffff' } do
        column(1).style align: :right
      end
      pdf.font_size 8 do
        pdf.indent 300 do
          pdf.text 'М. П.'
        end
      end
    end

  end
end