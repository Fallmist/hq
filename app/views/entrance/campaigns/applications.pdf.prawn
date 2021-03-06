prawn_document margin: [28.34645669291339, 28.34645669291339,
                        28.34645669291339, 56.692913386],
               page_size: 'A4', page_layout: :portrait do |pdf|

  render 'pdf/font', pdf: pdf

  pdf.font_size 12 do
    pdf.text "Пофамильный список лиц, подавших документы, необходимые для поступления, по состоянию на #{l Time.now}."
  end

  pdf.stroke do
    pdf.horizontal_rule
  end

  pdf.move_down 5

  pdf.font_size 13 do
    pdf.text @direction.department.name
  end

  pdf.move_down 5

  pdf.font_size 10 do
    pdf.text "#{@direction.new_code} #{@direction.name}", style: :bold
    pdf.text "#{@form.name}, #{Unicode::downcase(@source.name)}", style: :bold

    pdf.move_down 5

    pdf.text "Подано #{@applications.size} #{Russian::p(@applications.size, 'заявление', 'заявления', 'заявлений')}."
  end

  pdf.font_size 9 do
    @applications.each_with_index do |application, index|
      pdf.text "#{index + 1}. #{application.number}, #{application.entrant.full_name}, #{application.entrance_type}"
    end
  end
end
