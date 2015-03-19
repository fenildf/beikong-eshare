# -*- coding: utf-8 -*-
class Course < ActiveRecord::Base
  include CourseZipImporter
  include CourseZipExporter
  include YamlCoursesExporter
  include YamlCoursesImporter
  include CourseInteractive::CourseMethods
  include CourseSignModule
  include CourseReadPercent::CourseMethods
  include YoukuVideoList::CourseMethods
  include TudouVideoList::CourseMethods
  include CourseFav::CourseMethods
  include SelectCourse::CourseMethods
  include Note::CourseMethods
  include CourseAttitude::CourseMethods
  include CourseUpdateStatusMethods
  include CourseScore::CourseMethods
  include CourseTeacher::CourseMethods
  include Announcement::HostableMethods

  simple_taggable
  BASE_TAGS = %w(
    计算机技术
    数学与逻辑学
    实验与理论科学
    机械与工程
    历史与社会
    哲学与伦理
    认知与心理
    天文与地理
    医学与生理
    生物与环境科学
    经济管理与法律
    语言文学
    艺术审美
    动漫创作
    教育学
    游戏
    生活
  )
  
  def replace_public_tags(tags_str, user)
    return true if tags_str.blank?
    self.remove_public_tag self.public_tags.map(&:name).join(' ')
    self.set_tag_list(tags_str, :user => user, :force_public => true)
  end

  attr_accessible :name, :cid, :desc, :syllabus, :cover, :creator, :with_chapter, 
                  :time, :location,
                  :lesson_hour, :credit, 
                  :least_user_count, :most_user_count, 
                  :teach_type, :teach_content,
                  :category_id

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  belongs_to :category

  scope :of_category, lambda{ |category| 
    where(:category_id => category.id)
  }

  has_many :chapters
  has_many :practices, :through => :chapters
  has_many :course_wares, :through => :chapters
  has_many :course_ware_readings, :through => :course_wares

  has_many :directly_course_ware_readings, :class_name => 'CourseWareReading', 
                                           :foreign_key => :course_id
  has_many :learning_users, :through => :directly_course_ware_readings,
                            :source => :user,
                            :uniq => true

  has_many :test_questions
  has_one  :test_option
  
  has_many :course_signs

  has_many :test_papers

  has_many :questions
  has_many :question_answers, :through => :questions,
                              :source => :answers

  validates :name, :presence => true
  validates :creator, :presence => true

  validates :cid, :uniqueness => {:case_sensitive => false},
                  :presence => true


  validates :inhouse_kind, :inclusion => { :in => COURSE_INHOUSE_KINDS + [nil] }

  validates :least_user_count, :most_user_count, :lesson_hour, :credit,
            :presence => true

  scope :of_creator, lambda { |creator| where(:creator_id => creator.id) }

  scope :by_category_grade_kclass, lambda {|category, grade, kclass|
    q = "LEFT OUTER JOIN group_tree_nodes ON group_tree_nodes.manage_user_id = courses.creator_id"

    joins(q)
      .where(:category_id => category.id)
      .where(:group_tree_nodes => {
               :manage_user_id => kclass.manage_user_id,
               :group_kind => GroupTreeNode::GROUP_KIND::KCLASS,
               :parent_id  => grade.id})
  }



  default_scope order('courses.id desc')
  max_paginates_per 50

  # carrierwave
  mount_uploader :cover, CourseCoverUploader

  # excel import
  simple_excel_import :course, :fields => [:name, :cid, :desc]
  def self.import(excel_file, creator)
    courses = self.parse_excel_course excel_file
    courses.each do |c|
      c.creator = creator
      c.save
    end
  end

  # 问题数统计
  def questions_count
    self.chapters.map { |c| c.questions.count }.sum
  end

  # 用户学习进度排名
  def users_rank
    sql = %~
      SELECT * FROM
      (
        SELECT 
          sum(CW.read_percent) AS S1, 
          CW.user_id AS USER_ID

        FROM course_ware_readings AS CW
        WHERE CW.course_id = #{self.id}
        GROUP BY CW.user_id
      ) AS Q
      ORDER BY S1 DESC
    ~

    result = Course.find_by_sql sql

    index = 0 
    result.map do |r|
      index = index + 1
      {
        :user => User.find_by_id(r['USER_ID']),
        :sum => r['S1'],
        :index => index
      }
    end
  end

  def user_rank_of(user)
    users_rank.each do |r|
      return r[:index] if user == r[:user]
    end

    return '无'
  end

  # 给视频类课程根据其中的视频设置封面
  def set_video_course_cover
    return if course_wares.blank?
    cw = course_wares.first
    if cw.is_tudou? || cw.is_youku?
      url = cw.cover_url
      return if url.blank?
      require 'open-uri'

      tmpfile = Tempfile.new('foo')
      path = "#{tmpfile.path}.png"

      open(path, 'wb') do |file|
        file << open(url).read
      end

      file = File.new path

      p file.size
      self.cover = file
      self.save
    end
  end

  # 获取指定用户在课程下的课件学习情况
  def course_wares_read_stat_of(user)
    scope = self.directly_course_ware_readings.where(:user_id => user.id)

    reading = scope.where('course_ware_readings.read_percent <> ?', '100%').count
    read    = scope.where('course_ware_readings.read_percent = ?', '100%').count
    none    = self.course_wares.count - reading - read

    return {
      :none => none,
      :read => read,
      :reading => reading
    }
  end

  # 课程下还没有人回答的问题
  #TODO ISSUE 103 之后重构
  def questions_without_answers
    sql = %~
      SELECT * FROM
      (
        SELECT questions.*, count(answers.id) AS CA from questions
        LEFT JOIN answers 
        ON answers.question_id = questions.id 
        WHERE questions.course_id = #{self.id}
        GROUP BY questions.id
      ) AS Q

      WHERE CA = 0
    ~

    Question.find_by_sql sql
  end

  # 课程下还没有人回答的问题数目
  def questions_without_answers_count
    sql = %~
      SELECT count(*) AS CC FROM
      (
        SELECT questions.*, count(answers.id) AS CA from questions
        LEFT JOIN answers 
        ON answers.question_id = questions.id 
        WHERE questions.course_id = #{self.id}
        GROUP BY questions.id
      ) AS Q

      WHERE CA = 0
    ~

    Question.find_by_sql(sql)[0]['CC']
  end

  module UserMethods
    def self.included(base)
      base.has_many :courses, :foreign_key => 'creator_id'
    end

    # 统计所有年份中，按照月份和星期分布的学习进度
    def course_weekdays_stat
      sql = %~
        SELECT weekday, month, SUM(percent_change) AS COUNT
        FROM course_ware_reading_delta
        WHERE user_id = #{self.id}
        GROUP BY weekday, month
      ~

      result = CourseWareReadingDelta.find_by_sql sql
      hash = Hash.new Hash.new

      max = 0

      result.each do |r|
        hash[r.month] = {} if hash[r.month].blank?
        count = r['COUNT'].to_i
        hash[r.month][r.weekday] = count
        max = [max, count].max
      end

      hash[:max] = max
      hash
    end

    def course_weekdays_stat_debug
      hash = Hash.new Hash.new

      12.times do |m|
        0.upto 6 do |w|
          hash[m][w] = rand(10) + rand(50)
        end
      end

      hash[:max] = 60
      hash
    end

    # 统计已学的，未学的，正在学的课程的个数
    def course_read_stat
      sql = %~
        SELECT COUNT(*) AS C FROM

        (
          SELECT Q.id, COUNT(Q.CWID) AS COURSE_WARE_COUNT, SUM(Q.read IS TRUE) AS HAS_READ, SUM(Q.read IS NOT TRUE AND P > 0) AS READING
          FROM
          (
              SELECT courses.id, course_wares.id AS CWID, (course_ware_readings.read_count / course_wares.total_count) AS P, course_ware_readings.read
              FROM courses
              INNER JOIN chapters ON chapters.course_id = courses.id
              INNER JOIN course_wares ON course_wares.chapter_id = chapters.id
              LEFT OUTER JOIN course_ware_readings 
                ON course_ware_readings.course_ware_id = course_wares.id
                AND course_ware_readings.user_id = #{self.id}
          ) AS Q
          GROUP BY Q.id

        ) AS Q1

        WHERE COURSE_WARE_COUNT > 0 AND ?
      ~

      read    = Course.count_by_sql sql.sub('?', 'COURSE_WARE_COUNT = HAS_READ')
      reading = Course.count_by_sql sql.sub('?', 'READING > 0')
      none = Course.count - reading - read

      return {
        :none => none,
        :read => read,
        :reading => reading
      }
    end


    def own_courses
      data = []
      CourseTeacher.by_user(self).each { |course_teacher| data << course_teacher.course }

      courses.each { |course| data << course }

      data.uniq
    end

    def has_own_course?(course)
      self.own_courses.include? course
    end
  end

  # searchable do
  #   text :name, :desc

  #   text :chapter_titles do
  #     chapters.pluck("chapters.title").uniq.compact
  #   end

  #   text :chapter_descs do
  #     chapters.pluck("chapters.desc").uniq.compact
  #   end

  #   text :course_ware_titles do
  #     course_wares.pluck("course_wares.title").uniq.compact
  #   end

  #   text :chapter_descs do
  #     course_wares.pluck("course_wares.desc").uniq.compact
  #   end
  # end
end
