class PracticesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @practices = current_user.assigned_practices.page params[:page]
  end

  def check
    @practice = Practice.find params[:id]
    @user = User.find params[:user_id]
  end

  def show
    @practice = Practice.find params[:id]
  end

  # 学生提交作业，以及附件
  # 逻辑参考 http://s.4ye.me/xcw8p4
  def do_submit_record
    @practice = Practice.find params[:id]

    if params[:file_entity_id].present?
      fe = FileEntity.find(params[:file_entity_id])
      @practice.add_upload(current_user, fe)
    end

    @practice.submit_by_user(current_user, params[:practice_record][:submit_desc])

    redirect_to @practice
  end

  # 老师给学生作业打分
  def do_check_score
    score = params[:practice_record][:score]

    if score.present?
      record = PracticeRecord.find params[:record]
      record.score = score
      record.status = PracticeRecord::Status::CHECKED
      record.save
    end

    redirect_to :back
  end
end