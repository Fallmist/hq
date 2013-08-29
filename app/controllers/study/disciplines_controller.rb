class Study::DisciplinesController < ApplicationController
  before_filter :load_user_disciplines, only: :index
  before_filter :load_user_discipline,  only: [:show, :destroy]
  load_and_authorize_resource except: [:create]

  def index ; end

  def new
    # Создаём для дисциплины заготовку для итогового испытания
    # и 3-х дополнительных преподавателей.
    @discipline.exams.build
    3.times { @discipline.discipline_teachers.build }

    # Подгружаем коллег пользователя со всех кафедр, на которых он работает.
    # Их пользователь сможет выбрать в качестве ведущего преподавателя.
    # (Хотя может лучше сделать по-другому!?)
    detect_lead_teacher
    load_user_colleagues
  end

  def edit
    @teachers = []
      if @discipline.teachers.count != 0
        @discipline.teachers.each do |teacher|
          @teachers << teacher.id if teacher != @discipline.teacher
         end
      end
  end

  def show ; end

  def create
    authorize! :create, Study::Discipline
    @discipline = Study::Discipline.new(resource_params)
    if @discipline.save
      # При необходимости, создаём записи о курсовой работе и курсовом проекте.
      @discipline.add_semester_work    if '1' == params[:has_semester_work]
      @discipline.add_semester_project if '1' == params[:has_semester_project]

      redirect_to study_disciplines_path, notice: 'Дисциплина успешно добавлена.'
    else
      # В случае ошибки необходимо вручную инициализировать поля для выбора
      # группы в том случае, если пользователь уже сделал свой выбор и ошибка
      # в каких-то других полях формы.
      #
      # Кроме того, нужно инициализировать массив с коллегами пользователя.
      if @discipline && @discipline.group
        @faculty = @discipline.group.speciality.faculty
        @speciality = @discipline.group.speciality
      end

      detect_lead_teacher
      load_user_colleagues

      render action: :new
    end
  end

  def update
    authorize! :update, Study::Discipline
    if @discipline.update(resource_params)
      redirect_to study_discipline_checkpoints_path(@discipline), notice: 'Изменения успешно сохранены.'
    else
      if resource_params.include?(:checkpoints_attributes)
        # Идёт редактирование контрольных точек — возвращаем туда.
        render template: 'study/checkpoints/new'
        return
      else
        #raise '123'
        #render action: :edit
      end
    end
  end

  def destroy
    @discipline.destroy

    redirect_to study_disciplines_path
  end

  def resource_params
    params.fetch(:study_discipline, {}).permit(
        :year, :semester, :group, :subject_group, :name, :subject_teacher,
        exams_attributes: [:exam_type, :exam_weight],
        discipline_teachers_attributes: [:teacher_id],
        lectures_attributes: [:id, :checkpoint_date, :'_destroy'],
        seminars_attributes: [:id, :checkpoint_date, :'_destroy'],
        checkpoints_attributes: [:id, :checkpoint_date,
                                 :checkpoint_name, :checkpoint_details,
                                 :checkpoint_max, :checkpoint_min, :'_destroy']
    )
  end

  private

  def load_user_discipline
    @discipline = Study::Discipline.include_teacher(current_user).find(params[:id])
  end

  def load_user_disciplines
    @disciplines = Study::Discipline.include_teacher(current_user)
  end

  def detect_lead_teacher
    @lead_teacher = current_user unless @discipline
    if @discipline.lead_teacher
      @lead_teacher = @discipline.lead_teacher
    else
      @lead_teacher = current_user
    end
  end

  def load_user_colleagues
    @teachers = []
    current_user.departments.academic.each do |d|
      @teachers = @teachers.concat(d.users.to_a)
    end
  end
end