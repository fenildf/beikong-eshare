class SelectCourseIntentsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :set_subsystem
  def set_subsystem
    @subsystem = :xuanke
  end  

  def index
    @courses = Course.approve_status_with_yes
  end

  def save
    _save(:first)
    _save(:second)
    _save(:third)

    redirect_to '/select_course_intents'
  end

  def _save(flag)
    id = params["#{flag}_intent"]
    if id.present?
      course = Course.find id
      current_user.set_select_course_intent(flag, course)
    end
  end

  def save_one
    course = Course.find params[:course_id]
    current_user.add_course_intent(course)

    render :json => {
      :status => 'ok',
      :html => (
        render_cell :admin, :course_select_tables, :courses => [course], :user => current_user
      )
    }
  end

  def remove_one
    course = Course.find params[:course_id]
    current_user.remove_course_intent(course)

    render :json => {
      :status => 'ok',
      :html => (
        render_cell :admin, :course_select_tables, :courses => [course], :user => current_user
      )
    }
  end
end