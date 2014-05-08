module PracticeHelper
  def user_practice_status(user, practice)
    if practice.in_submitted_status_of_user?(user) || 
       practice.in_submitted_offline_of_user?(user)
      return "已经提交"
    end

    if practice.in_checked_status_of_user?(user)
      return "已经打分"
    end
    
    return "未提交"
  end

  def user_practice_score(user, practice)
    record = practice.get_record_by_user(user)

    if record.blank? || record.score.blank?
      s = haml_tag 'span.quiet', '未打分'
    else
      s = haml_tag 'span', record.score
    end

    capture_haml {
      s
    }
  end
end