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

  module ClassMethods
    # 志愿课程排行
    def intent_course_ranking(options = {})
      flag = options[:flag]
      group_tree_node = options[:group_tree_node]

      return __course_ranking(group_tree_node) if flag.blank?
      return __course_ranking_with_flag(flag, group_tree_node)
    end

    def __course_ranking(group_tree_node)
      sql = %`
        SELECT courses.*,  C1, C2, C3, (IFNULL(C1, 0) + IFNULL(C2, 0) + IFNULL(C3, 0)) AS TOTAL FROM courses

        LEFT OUTER JOIN
        (
          SELECT count(1) AS C1, first_course_id
          FROM select_course_intents
          #{___group_tree_node_joins_sub_sql(group_tree_node)}
          WHERE first_course_id IS NOT NULL
          GROUP BY first_course_id
        ) AS F1 ON courses.id = F1.first_course_id

        LEFT OUTER JOIN
        (
          SELECT count(1) AS C2, second_course_id
          FROM select_course_intents
          #{___group_tree_node_joins_sub_sql(group_tree_node)}
          WHERE second_course_id IS NOT NULL
          GROUP BY second_course_id
        ) AS F2 ON courses.id = F2.second_course_id

        LEFT OUTER JOIN
        (
          SELECT count(1) AS C3, third_course_id
          FROM select_course_intents
          #{___group_tree_node_joins_sub_sql(group_tree_node)}
          WHERE third_course_id IS NOT NULL
          GROUP BY third_course_id
        ) AS F3 ON courses.id = F3.third_course_id
        WHERE C1 IS NOT NULL OR C2 IS NOT NULL OR C3 IS NOT NULL
        ORDER BY TOTAL DESC
      `
      Course.find_by_sql(sql)
    end

    def __course_ranking_with_flag(flag, group_tree_node)
      column_name = "#{flag}_course_id"

      sql = %`
        SELECT courses.*, C, IFNULL(C, 0) AS TOTAL FROM courses

        LEFT OUTER JOIN
        (
          SELECT count(1) AS C, #{column_name}
          FROM select_course_intents
          #{___group_tree_node_joins_sub_sql(group_tree_node)}
          WHERE #{column_name} IS NOT NULL
          GROUP BY #{column_name}
        ) AS F1 ON courses.id = F1.#{column_name}
        WHERE C IS NOT NULL
        ORDER BY TOTAL DESC
      `
      Course.find_by_sql(sql)
    end

    def ___group_tree_node_joins_sub_sql(group_tree_node)
      group_tree_node.blank? ? '' : %~
        JOIN group_tree_node_users 
        ON 
          group_tree_node_users.user_id = select_course_intents.user_id
            AND
          group_tree_node_users.group_tree_node_id = #{group_tree_node.id}
      ~
    end
    
  end


  module CourseMethods
    def batch_check(flag)
      users = self.intent_users(:flag => flag)
      users.each do |user|
        user.select_course(:accept, self)
      end
    end

    def intent_users_count(options = {})
      flag = options[:flag]
      group_tree_node = options[:group_tree_node]

      if group_tree_node.blank?
        if flag.present?
          return SelectCourseIntent.where("#{flag}_course_id" => self.id).count
        end
        return SelectCourseIntent.where("first_course_id = ? OR second_course_id = ? OR third_course_id = ?", self.id, self.id, self.id).count
      end

      if flag.present?

        return SelectCourseIntent
          .where("#{flag}_course_id" => self.id)
          .joins("INNER JOIN group_tree_node_users ON group_tree_node_users.user_id = select_course_intents.user_id AND group_tree_node_users.group_tree_node_id = #{group_tree_node.id}")
          .count()
      end
      return SelectCourseIntent
        .where("first_course_id = ? OR second_course_id = ? OR third_course_id = ?", self.id, self.id, self.id)
        .joins("INNER JOIN group_tree_node_users ON group_tree_node_users.user_id = select_course_intents.user_id AND group_tree_node_users.group_tree_node_id = #{group_tree_node.id}")
        .count()
    end

    def intent_users(options = {})
      flag = options[:flag]
      group_tree_node = options[:group_tree_node]

      return __intent_users_with_flag(flag, group_tree_node) if flag.present?

      __intent_users_without_flag(group_tree_node)
    end

    def __intent_users_with_flag(flag, group_tree_node)
      column_name = "#{flag}_course_id"
      sci_joins = %`
        INNER JOIN 
          select_course_intents 
        ON 
          select_course_intents.user_id = users.id 
            AND 
          select_course_intents.#{column_name} = #{self.id}
      `
      return User.joins(sci_joins) if group_tree_node.blank?

      User.joins(sci_joins).joins(___intent_users_sub_sql(group_tree_node))
    end

    def __intent_users_without_flag(group_tree_node)
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

      return User.joins(sci_joins) if group_tree_node.blank?

      User.joins(sci_joins).joins(___intent_users_sub_sql(group_tree_node))
    end

    def ___intent_users_sub_sql(group_tree_node)
      %`
        INNER JOIN
          group_tree_node_users
        ON
          group_tree_node_users.user_id = users.id
            AND
          group_tree_node_users.group_tree_node_id = #{group_tree_node.id}
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