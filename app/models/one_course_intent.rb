class OneCourseIntent < ActiveRecord::Base
  attr_accessible :user, :course

  belongs_to :user
  belongs_to :course

  validates :user,    :presence => true
  validates :course,  :presence => true
  validates :user_id,  :uniqueness => {:scope => :course_id}

  module ClassMethods
    def need_adjust_users
      join_sql = %`
      INNER JOIN 
        (
          SELECT users.id AS id, sum(IFNULL(courses.credit, 0)) AS sum FROM users
            LEFT OUTER JOIN select_courses
            ON select_courses.user_id = users.id
            LEFT OUTER JOIN courses
            ON courses.id = select_courses.course_id
          GROUP BY
            users.id
        ) AS user_and_sums
      ON
        user_and_sums.id = users.id 
      AND 
        user_and_sums.sum < #{R::LEAST_SELECT_CREDIT}
      `

      User.joins(join_sql).with_role(:student)
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :one_course_intents
      base.has_many :intent_courses, :through => :one_course_intents, :source => :course
    end

    def add_course_intent(course)
      return if intent_courses.include?(course)

      self.one_course_intents.create(:course => course)
    end
  end

  module CourseMethods
    def self.included(base)
      base.has_many :one_course_intents
    end

    def intent_users(options = {})
      team = options[:team]
      order_by_sql = %`
        one_course_intents.created_at ASC
      `

      oci_join_sql = %`
        INNER JOIN 
          one_course_intents 
        ON 
          one_course_intents.user_id = users.id 
            AND 
          one_course_intents.course_id = #{self.id}
      `
      return User.joins(oci_join_sql).order(order_by_sql) if team.blank?
      
      team_join_sql = %`
        INNER JOIN team_memberships 
        ON 
          team_memberships.user_id = one_course_intents.user_id
            AND
          team_memberships.team_id = #{team.id}
      `

      User.joins(oci_join_sql).joins(team_join_sql).order(order_by_sql)
    end

    def intent_users_count(options = {})
      team = options[:team]

      if team.blank?
        return OneCourseIntent.where(:course_id => self.id).count
      end

      team_join_sql = %`
        INNER JOIN team_memberships 
        ON 
          team_memberships.user_id = one_course_intents.user_id
            AND
          team_memberships.team_id = #{team.id}
      `

      return OneCourseIntent
        .joins(team_join_sql)
        .where(:course_id => self.id).count
    end

    def select_status_of_user(user)
      return "选中" if self.selected_users.include?(user)
      return "未选中" if self.be_reject_selected_users.include?(user)
      return "等待志愿分配" if self.intent_users.include?(user)
      return "未申请"
    end

    def intent_status
      iucount = self.intent_users_count

      return "无人申请" if iucount == 0
      return "人数过少" if iucount < self.least_user_count
      return "人数适合" if iucount >= least_user_count && iucount <= most_user_count
      return "人数过多"
    end

    # 批量处理申请，先到先得
    def batch_check
      users = self.intent_users
      accept_users = users[0...self.most_user_count] || []
      reject_users = users[self.most_user_count..-1] || []
      accept_users.each do |user|
        user.select_course(:accept, self)
      end

      reject_users.each do |user|
        user.select_course(:reject, self)
      end
    end
  end
end
