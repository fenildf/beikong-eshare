class CourseSelectCell < Cell::Rails
  helper :application

  def manage_table(opts = {})
    @users = opts[:users]
    @course = opts[:course]
    render
  end
end