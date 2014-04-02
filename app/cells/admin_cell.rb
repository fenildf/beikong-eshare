class AdminCell < Cell::Rails
  helper :application

  def form_user_role_select(opts = {})
    @form_object = opts[:form_object]
    render
  end

  def course_manage_tables(opts = {})
    @courses = opts[:courses]
    @user = opts[:user]
    render
  end

  def course_manage_design_tables(opts = {})
    @courses = opts[:courses]
    @user = opts[:user]
    render
  end

  def course_select_tables(opts = {})
    @courses = opts[:courses]
    @user = opts[:user]
    render
  end

  def course_form(opts = {})
    @course = opts[:course]
    @cur_user = opts[:user]
    render
  end

  def course_ajax_edit_form(opts = {})
    @course = opts[:course]
    @cur_user = opts[:user]
    render
  end

  def chapter_ajax_edit_form(opts = {})
    @chapter = opts[:chapter]
    @cur_user = opts[:user]
    render
  end
end