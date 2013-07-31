class SelectCourseIntent < ActiveRecord::Base
  attr_accessible :user, 
                  :first_course, 
                  :second_course, 
                  :third_course, 
                  :opinion

  belongs_to :user

  belongs_to :first_course,  :class_name => "Course"
  belongs_to :second_course, :class_name => "Course"
  belongs_to :third_course,  :class_name => "Course"

  validates :user, :presence => true

  # 志愿课程排行
  def self.intent_course_ranking(options = {})
    flag = options[:flag]
    team = options[:team]

    return __course_ranking(team) if flag.blank?
    return __course_ranking_with_flag(flag, team)
  end

  def self.__course_ranking(team)
    sql = %`
      SELECT courses.*,  C1, C2, C3, (IFNULL(C1, 0) + IFNULL(C2, 0) + IFNULL(C3, 0)) AS TOTAL FROM courses

      LEFT OUTER JOIN
      (
        SELECT count(1) AS C1, first_course_id
        FROM select_course_intents
        #{___team_joins_sub_sql(team)}
        WHERE first_course_id IS NOT NULL
        GROUP BY first_course_id
      ) AS F1 ON courses.id = F1.first_course_id

      LEFT OUTER JOIN
      (
        SELECT count(1) AS C2, second_course_id
        FROM select_course_intents
        #{___team_joins_sub_sql(team)}
        WHERE second_course_id IS NOT NULL
        GROUP BY second_course_id
      ) AS F2 ON courses.id = F2.second_course_id

      LEFT OUTER JOIN
      (
        SELECT count(1) AS C3, third_course_id
        FROM select_course_intents
        #{___team_joins_sub_sql(team)}
        WHERE third_course_id IS NOT NULL
        GROUP BY third_course_id
      ) AS F3 ON courses.id = F3.third_course_id
      WHERE C1 IS NOT NULL OR C2 IS NOT NULL OR C3 IS NOT NULL
      ORDER BY TOTAL DESC
    `
    Course.find_by_sql(sql)
  end

  def self.__course_ranking_with_flag(flag, team)
    column_name = "#{flag}_course_id"

    sql = %`
      SELECT courses.*, C, IFNULL(C, 0) AS TOTAL FROM courses

      LEFT OUTER JOIN
      (
        SELECT count(1) AS C, #{column_name}
        FROM select_course_intents
        #{___team_joins_sub_sql(team)}
        WHERE #{column_name} IS NOT NULL
        GROUP BY #{column_name}
      ) AS F1 ON courses.id = F1.#{column_name}
      WHERE C IS NOT NULL
      ORDER BY TOTAL DESC
    `
    Course.find_by_sql(sql)
  end

  def self.___team_joins_sub_sql(team)
    team.blank? ? '' : %~
      JOIN team_memberships 
      ON 
        team_memberships.user_id = select_course_intents.user_id
          AND
        team_memberships.team_id = #{team.id}
    ~
  end

  module CourseMethods
    def intent_student_count(options = {})
      flag = options[:flag]
      team = options[:team]

      if team.blank?
        if flag.present?
          return SelectCourseIntent.where("#{flag}_course_id" => self.id).count
        end
        return SelectCourseIntent.where("first_course_id = ? OR second_course_id = ? OR third_course_id = ?", self.id, self.id, self.id).count
      end

      if flag.present?

        return SelectCourseIntent
          .where("#{flag}_course_id" => self.id)
          .joins("INNER JOIN team_memberships ON team_memberships.user_id = select_course_intents.user_id AND team_memberships.team_id = #{team.id}")
          .count()
      end
      return SelectCourseIntent
        .where("first_course_id = ? OR second_course_id = ? OR third_course_id = ?", self.id, self.id, self.id)
        .joins("INNER JOIN team_memberships ON team_memberships.user_id = select_course_intents.user_id AND team_memberships.team_id = #{team.id}")
        .count()
    end

    def intent_student_users(options = {})
      flag = options[:flag]
      team = options[:team]

      return __intent_student_users_with_flag(flag, team) if flag.present?

      __intent_student_users_without_flag(team)
    end

    def __intent_student_users_with_flag(flag, team)
      column_name = "#{flag}_course_id"
      sci_joins = %`
        INNER JOIN 
          select_course_intents 
        ON 
          select_course_intents.user_id = users.id 
            AND 
          select_course_intents.#{column_name} = #{self.id}
      `
      return User.joins(sci_joins) if team.blank?

      User.joins(sci_joins).joins(___intent_student_users_sub_sql(team))
    end

    def __intent_student_users_without_flag(team)
      sci_joins = %`
        INNER JOIN 
          select_course_intents 
        ON 
          select_course_intents.user_id = users.id 
            AND
          (
            select_course_intents.first_course_id = #{self.id}
              OR
            select_course_intents.second_course_id = #{self.id}
              OR
            select_course_intents.third_course_id = #{self.id}
          )
      `

      return User.joins(sci_joins) if team.blank?

      User.joins(sci_joins).joins(___intent_student_users_sub_sql(team))
    end

    def ___intent_student_users_sub_sql(team)
      %`
        INNER JOIN
          team_memberships
        ON
          team_memberships.user_id = users.id
            AND
          team_memberships.team_id = #{team.id}
      `
    end
  end

  module UserMethods
    def self.included(base)
      base.has_one :select_course_intent, :foreign_key => 'user_id'
    end

    def set_select_course_intent(flag, course)
      return false if !_check_course?(course)
      _select_course_intent.update_attributes "#{flag}_course" => course
    end

    # ----------------
    def course_intent(flag)
      _select_course_intent.send("#{flag}_course")
    end

    # ----------------


    private
      def _select_course_intent
        self.select_course_intent || self.create_select_course_intent
      end

      def _check_course?(course)
        approved      = Course.approve_status_with_yes.include?(course)
        check_first   = course != _select_course_intent.first_course
        check_second  = course != _select_course_intent.second_course
        check_third   = course != _select_course_intent.third_course
        approved && check_first && check_second && check_third
      end
  end
end