class Office::OrdersController < ApplicationController
  load_and_authorize_resource class: 'Office::Order'
  before_filter :find_faculties, only: [:index, :drafts, :underways]

  def index
    params[:from_date]  ||= "01.01.#{Date.today.year}"
    @order_students = Office::OrderStudent.my_filter(params.merge(order_status: Office::Order::STATUS_SIGNED))
    if params[:group_by_number] == '1'
      @order_students = @order_students.group(:order_student_order)
    end
    if @order_students.page(params[:page]).empty?
      @order_students = @order_students.page(1)
    else
      @order_students = @order_students.page(params[:page])
    end
  end

  def drafts
    params[:from_date]  ||= "01.01.#{Date.today.year}"
    @order_students = Office::OrderStudent.my_filter(params.merge(order_status: Office::Order::STATUS_DRAFT))
    @drafts = Office::Order.where(id: @order_students.collect{|x| x.order.id}.uniq)
    if @drafts.page(params[:page]).empty?
      @drafts = @drafts.page(1)
    else
      @drafts = @drafts.page(params[:page])
    end
  end

  def underways
    params[:from_date]  ||= "01.01.#{Date.today.year}"
    @order_students = Office::OrderStudent.my_filter(params.merge(order_status: Office::Order::STATUS_UNDERWAY))
    @underways = Office::Order.where(id: @order_students.collect{|x| x.order.id}.uniq)
    if @underways.page(params[:page]).empty?
      @underways = @underways.page(1)
    else
      @underways = @underways.page(params[:page])
    end
  end

  def entrance_protocol
    @item = @order.competitive_group.items.first if Office::Order.entrance.include? @order
    respond_to do |format|
      format.pdf
    end
  end

  def show
    respond_to do |format|
      format.pdf {
        filename = "Приказ №#{@order.id}"
        Dir.chdir(Rails.root)
        url = "#{Dir.getwd}/lib/xsl"
        xml = Tempfile.new(['order', '.xml'])
        File.open(xml.path, 'w') do |file|
          file.write @order.to_xml
        end
        command = "java -cp #{Dir.getwd}/vendor/fop/build/fop.jar"
        Dir.foreach('vendor/fop/lib') do |file|
          command << ":#{Dir.getwd}/vendor/fop/lib/#{file}" if (file.match(/.jar/))
        end
        command << ' org.apache.fop.cli.Main '
        command << " -c #{url}/configuration.xml"
        command << " -xml #{xml.path}"
        command << " -xsl #{url}/order_print.xsl"
        command << ' -pdf -'
        document = `#{command}`

        send_data document,
                  type: 'application/pdf',
                  filename: "#{filename}.pdf",
                  disposition: 'inline'

        xml.close
        xml.unlink
      }
      format.xml { render xml: @order.to_xml }
    end
  end

  def new
    @students = Student.includes([:person, :group]).where.not(student_group_id: params[:exception]).my_filter(params).page(params[:page])
  end

  def create
    students = {}
    params[:exception].each_with_index do |ex, i|
      student = Student.find(ex)
      students.merge! i => {order_student_student: student.person.id, order_student_student_group_id: student.id, order_student_cause: 0}
    end
    # raise students.inspect
    @order = Office::Order.create status: 1, responsible: current_user.positions.first.id, order_template: params[:template],
                                  order_department:  current_user.positions.first.department.id,
                                  students_in_order_attributes: students
    if @order.save
      redirect_to office_orders_path, notice: 'Проект приказа успешно создан.'
    else
      render action: :new
    end
  end

  def edit ; end

  def update
    @order.update(resource_params)
    if @order.save
      if can?(:sign, Office::Order) && @order.status == Office::Order::STATUS_SIGNED
        redirect_to edit_office_order_path(@order)
      elsif can?(:orders, Entrance::Campaign)
        redirect_to orders_entrance_campaigns_path
      elsif @order.underway?
        redirect_to office_underways_path, notice: 'Изменения сохранены.'
      else
        redirect_to office_orders_path, notice: 'Изменения сохранены.'
      end
    else
      render action: :edit
    end
  end

  def destroy
    @order.destroy

    redirect_to office_drafts_path
  end

  def resource_params
    params.fetch(:office_order, {}).permit(:number, :editing_date, :signing_date, :status, :responsible, :template,
                 students_in_order_attributes: [:order_student_student, :order_student_student_group_id, :order_student_cause])
  end

  private

  def find_faculties
    @faculties = Department.faculties
    unless current_user.is?(:developer)
      user_departments = current_user.departments_ids
      @faculties = @faculties.find_all { |f| user_departments.include?(f.id) }
    end
    params[:faculty] ||= @faculties.first.id
  end
end