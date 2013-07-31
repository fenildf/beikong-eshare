class SelectCourseIntentsController < ApplicationController
  before_filter :authenticate_user!
  layout Proc.new { |controller|
    case controller.action_name
    when 'index'
      return 'grid'
    else
      return 'application'
    end
  }

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
end