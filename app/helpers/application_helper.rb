module ApplicationHelper
  def truncate_u(text, length = 30, truncate_string = "...")
    # truncate(text, :length => length, :separator => truncate_string)
    return '' if text.blank?

    re = ''
    count = 0
    text.chars.each do |char|
      re = re + char
      count = count + (char.ascii_only? ? 0.5 : 1)
      return "#{re}#{truncate_string}" if count >= length
    end

    return re
  end

  def avatar(user, style = :normal)
    klass = ['page-avatar', style] * ' '

    if user.blank?
      alt   = t('common.unknown-user')
      src   = User.new.avatar.versions[style].url
      meta  = 'unknown-user'
    else
      alt   = user.name
      src   = user.avatar.versions[style].url
      meta  = dom_id(user)
    end

    image_tag src, :alt => alt,
                   :class => klass,
                   :data => {
                      :meta => meta
                   }
  end

  def avatar_link(user, style = :normal)
    if user.blank?
      return link_to 'javascript:;', :class => 'u-avatar' do
        avatar user, style
      end
    end

    link_to "/users/#{user.id}", :class => 'u-avatar', :title => user.name do
      avatar user, style
    end
  end

  def string_grid_color(str)
    colors = 
      %w(
        #1ABC9C #2ECC71 #3498DB #9B59B6 
        #34495E #F1C40F #E67E22 #E74C3C 
        #95A5A6
      )

    # 颜色来自 http://flatuicolors.com/

    md5 = Digest::MD5.hexdigest str.to_s
    i1 = md5[0..1].to_i(16) % colors.length
    i2 = md5[2..3].to_i(16) % colors.length
    i3 = md5[4..5].to_i(16) % 100

    c1 = colors[i1]
    c2 = colors[i2]

    bgc = ColorTransfer.mix(c1, c2, i3)
    # ColorTransfer.darken bgc.to_s
  end

  def user_link(user)
    return '未知用户' if user.blank?
    link_to user.name, "/users/#{user.id}", :class=>'u-name'
  end

  def course_link(course)
    return '<s class="quiet">课程已删除</s>'.html_safe if course.blank?
    link_to course.name, "/courses/#{course.id}", :title => course.name
  end

  def chapter_link(chapter)
    return '<s class="quiet">章节已删除</s>'.html_safe if chapter.blank?
    link_to chapter.title, "/chapters/#{chapter.id}", :title => chapter.title
  end

  def course_ware_link(course_ware)
    return '<s class="quiet">小节已删除</s>'.html_safe if course_ware.blank?
    link_to course_ware.title, "/course_wares/#{course_ware.id}", :title => course_ware.title
  end

  def question_link(question)
    return '<s class="quiet">问题已删除</s>'.html_safe if question.blank?
    link_to "“#{truncate_u(question.title, 32)}”", "/questions/#{question.id}", :title => question.title 
  end

  def practice_link(practice)
    return '<s class="quiet">作业已删除</s>'.html_safe if practice.blank?
    link_to "“#{truncate_u(practice.title, 32)}”", "/practices/#{practice.id}", :title => practice.title 
  end

  def course_ware_read_count_html(course_ware, user)
    return "" if user.blank? || course_ware.blank?

    # .read
    #   %span.desc 学习完成度
    #   %span.l= @read_count
    #   %span /
    #   %span.r= @total_count
    capture_haml {
      haml_tag '.read', :data => {:id => course_ware.id} do
        haml_tag 'span.desc', '学习完成度'
        haml_tag 'span.rc', course_ware.read_count_of(user)
        haml_tag 'span', '/'
        haml_tag 'span.tc', course_ware.total_count
      end
    }
  end

  # 获取课件的学习进度
  def course_ware_read_percent(course_ware, user = current_user)
    return '0%' if user.blank?
    course_ware.read_percent(user)
  end

  def course_ware_reading_css_class(course_ware, user = current_user)
    return '' if user.blank?

    percent = course_ware.read_percent(user)
    return '' if percent == '0%'
    return 'read' if percent == '100%'
    return 'reading'
  end

  # 获取章节的学习进度
  def chapter_read_percent(chapter)
    chapter.read_percent(current_user)
  end

  def follow_button(cur_user, user, klass = :small)
    # %a.page-follow.unfollow.btn.small{:data => {:id => user.id}}
    return '' if cur_user == user

    if cur_user.has_follow? user
      return capture_haml {
        haml_tag "a.page-follow.unfollow.btn.#{klass}", '取消关注', :data => {:id => user.id}, :href => 'javascript:;'
      }
    end

    capture_haml {
      haml_tag "a.page-follow.follow.btn.#{klass}", '关注', :data => {:id => user.id}, :href => 'javascript:;'
    }
  end

  def question_follow_button(cur_user, question)
    # %a.page-question-follow.unfollow.btn.small{:data => {:id => question.id}}

    if question.followed_by? cur_user
      return capture_haml {
        haml_tag 'a.page-question-follow.unfollow.btn', '取消关注', :data => {:id => question.id}, :href => 'javascript:;'
      }
    end

    capture_haml {
      haml_tag 'a.page-question-follow.follow.btn', '关注', :data => {:id => question.id}, :href => 'javascript:;'
    }
  end

  def page_tag(tag, sub_path)
    # %a.tag{:href => "/tags/#{@sub_path}/#{tag.name}", :data => {:name => tag.name}}= tag.name
    capture_haml {
      haml_tag 'a.page-tag.tag', :href => "/tags/#{sub_path}/#{tag.name}", :data => {:name => tag.name} do
        haml_tag 'i.icon-tag'
        haml_tag 'span', tag.name
      end
    }
  end

  def user_roles_str(user)
    return '' if user.blank? || user.roles.blank?
    rrr = {
      :student => '学生',
      :teacher => '教职工',
      :admin => '网络管理员',
      :manager => '教学处/教研室'
    }

    user.roles.map {|role|
      rrr[role]
    }.join('，')
  end

  def course_apply_status(apply)
    if apply.blank?
      klass = 'no'
      string = '未选'
    else
      klass = apply.status.downcase
      string = {
        SelectCourseApply::STATUS_REQUEST => '待审核',
        SelectCourseApply::STATUS_ACCEPT => '已批准',
        SelectCourseApply::STATUS_REJECT => '已拒绝'
      }[apply.status]
    end

    capture_haml {
      haml_tag 'span', :class => "page-apply-status #{klass}" do
        haml_tag 'span', "#{string}"
      end
    }
  end

  def manage_course_select_apply_status(course)
    count = course.apply_users.count

    return '空选' if count == 0
    return '未满' if !course.have_apply_request_limit? 

    return '未满' if course.apply_request_limit > count
    return '选满' if course.apply_request_limit == count
    return '超选' if course.apply_request_limit < count
  end

  def user_page_head_bg(user)
    # url = '/assets/user_page/default.png'
    # fit_image url, :height => 180

    capture_haml {
      haml_tag 'img', :src => user.userpage_head.versions[:default].url, :width => '100%'
    }
  end

  def course_update_status(course)
    status = course.get_update_status
    klass = status.downcase
    str = {
      :NOCHANGE => '',
      :UPDATED => '更新',
      :NEW => '新课程'
    }[status.to_sym]

    capture_haml {
      haml_tag 'span.course-update-status', str, :class => klass
    }
  end

  def course_check_field_value(value)
    if value.blank?
      return capture_haml {
        haml_tag 'span.blank', '未填写'
      }
    end

    return capture_haml {
      haml_tag 'span', value
    }
  end

  def course_approve_status_label(course)
    status = course.approve_status

    if status == 'WAITING'
      return capture_haml {
        haml_tag 'span.state.default.waiting', '等待审核'
      }
    end

    if status == 'YES'
      return capture_haml {
        haml_tag 'span.state.success.yes', '审核通过'
      }
    end

    if status == 'NO'
      return capture_haml {
        haml_tag 'span.state.error.no', '未通过'
      }
    end
  end

  # 返回 选中 未选中 等待志愿分配 未申请 四种状态
  def course_select_status_label(user, course)
    if course.selected_users.include?(user)
      if course.intent_student_users.include?(user)
        return capture_haml {
          haml_tag 'span.page-course-select-status.pass', '申请成功'
        }
      end

      return capture_haml {
        haml_tag 'span.page-course-select-status.pass', '调剂成功'
      }

    end

    if course.be_reject_selected_users.include?(user)
      return capture_haml {
        haml_tag 'span.page-course-select-status.reject', '申请未过'
      }
    end

    if course.intent_student_users.include?(user)
      return capture_haml {
        haml_tag 'span.page-course-select-status.wait', '等待处理'
      }
    end

    return capture_haml {
      haml_tag 'span.page-course-select-status.no', '未申请'
    }
  end

  def course_intent_stat_label(course)
      min = course.least_user_count
      max = course.most_user_count
      count = course.intent_student_count

      if count == 0
        return '无人选'
      end

      if min && count < min
        return '人数过少'
      end

      if max && count > max
        return '人数过多'
      end

      return '人数适合'
  end

  def course_selected_stat_label(course)
      min = course.least_user_count
      max = course.most_user_count
      count = course.selected_users.count

      if count == 0
        return '无人选'
      end

      if min && count < min
        return '人数过少'
      end

      if max && count > max
        return '人数过多'
      end

      return '人数适合'
  end

  def render_topnav
    if current_user.is_admin?
      render_cell :layout, :topnav_admin, :user => current_user, :for => @subsystem
    else
      render_cell :layout, :topnav, :user => current_user, :for => @subsystem
    end
  end

  module FeedHelper
    def feed_icon(feed)
      capture_haml {
        case feed.what
        when 'create_course_ware_reading', 'update_course_ware_reading'
          haml_tag 'div.feed-icon.course_ware_reading'
        when 'create_question', 'update_question'
          haml_tag 'div.feed-icon.question'
        when 'create_answer', 'update_answer'
          haml_tag 'div.feed-icon.answer'
        when 'create_answer_vote', 'update_answer_vote'
          haml_tag 'div.feed-icon.vote-up'
        else
          haml_tag 'div.feed-icon.common'
        end
      }
    end

    # 把 feed 信息转为页面显示的描述语句
    def feed_desc(feed)
      capture_haml {
        haml_tag 'span.feed-desc', :class => feed.what do
          case feed.what
            when 'create_question'
              haml_concat user_link(feed.who)
              haml_concat '提了一个问题'
              haml_concat question_link(feed.to)
            when 'update_question'
              haml_concat user_link(feed.who)
              haml_concat '修改了问题'
              haml_concat question_link(feed.to)

            when 'create_answer'
              if(answer = feed.to).present?
                if(question = answer.question).present?
                  haml_concat user_link(feed.who)
                  haml_concat '回答了问题'
                  haml_concat question_link(question)
                end
              end
            when 'update_answer'
              if(answer = feed.to).present?
                if(question = answer.question).present?
                  haml_concat user_link(feed.who)
                  haml_concat '修改了对问题'
                  haml_concat question_link(question)
                  haml_concat '的回答'
                end
              end

            when 'create_answer_vote', 'update_answer_vote'
              if (answer_vote = feed.to).present?
                if (answer = answer_vote.answer).present?
                  haml_concat user_link(feed.who)
                  haml_concat '赞成了'
                  haml_concat user_link(answer.creator)
                  haml_concat '在问题'
                  haml_concat question_link(answer.question)
                  haml_concat '中的回答'
                end
              end
            when 'create_course_ware_reading', 'update_course_ware_reading'
              if (course_ware_reading = feed.to).present?
                course = course_ware_reading.course
                chapter = course_ware_reading.chapter
                course_ware = course_ware_reading.course_ware

                haml_concat user_link(feed.who)
                haml_concat '学习了' if feed.what == 'update_course_ware_reading'
                haml_concat '开始学习' if feed.what == 'create_course_ware_reading'
                haml_concat course_link(course)
                haml_concat '课程下的'
                haml_concat course_ware_link(course_ware)
              end
            when 'update_user'
              haml_concat user_link(feed.who)
              haml_concat '把签名档改成了'
              haml_concat "\""
              haml_concat feed.data
              haml_concat "\""
            when 'create_practice_record'
              practice = feed.to.practice
              chapter = practice.chapter
              course = chapter.course
              haml_concat user_link(feed.who)
              haml_concat '提交了'
              haml_concat course_link(course)
              haml_concat '课程下的'
              haml_concat chapter_link chapter
              haml_concat '章节下的'
              haml_concat practice_link practice
              haml_concat '作业'
            else
              haml_concat feed.what
          end
        end
      }
    end

    def feed_content(feed)
      capture_haml {
        case feed.what
        when 'create_course_ware_reading', 'update_course_ware_reading'
          if (course_ware_reading = feed.to).present?
            haml_concat '目前学习进度'
            haml_concat course_ware_reading.read_percent
          end
        when 'create_question', 'update_question'
          if (question = feed.to).present?
            haml_concat truncate_u(question.content, 140)
          end
        when 'create_answer', 'update_answer'
          if (answer = feed.to).present?
            haml_concat truncate_u(answer.content, 140)
          end
        when 'create_answer_voto', 'update_answer_vote'
          if (answer_vote = feed.to).present?
            if (answer = answer_vote.answer).present?
              haml_concat truncate_u(answer.content, 140)
            end
          end
        end
      }
    end
  end

  module TimeHelper
    def timeago(time)
      return content_tag(:span, '未知', :class=>'date') if time.blank?
      
      local_time = time.localtime
      content_tag(:span, _friendly_relative_time(local_time), :class=>'date', :'data-date'=>local_time.to_i)
    end

    private
      # 根据当前时间与time的间隔距离，返回时间的显示格式
      # 李飞编写
      def _friendly_relative_time(time)
        current_time = Time.now
        seconds = (current_time - time).to_i
        
        return '片刻前' if seconds < 0
        return "#{seconds}秒前" if seconds < 60        
        return "#{seconds/60}分钟前" if seconds < 3600
        return time.strftime('%H:%M') if seconds < 86400 && current_time.day == time.day
        return time.strftime("#{time.month}月#{time.day}日 %H:%M") if current_time.year == time.year
        return time.strftime("%Y年#{time.month}月#{time.day}日 %H:%M")
      end
  end

  module UserGroupHelper
    # def user_groups_tag(user)
    #   groups = []
    #   user.joined_group_tree_nodes.each do |group|
    #     gs = groups.clone

    #     # 遍历 gs
    #     parent_flag = false
    #     gs.each do |g|
    #       # 如果新组的祖先节点在旧组里，移除
    #       if _is_parent(g, group)
    #         groups = groups - [g]
    #         next
    #       end

    #       # 如果新组的子孙节点在旧组里，不加入新组
    #       if _is_parent(group, g)
    #         parent_flag = true
    #         next
    #       end
    #     end

    #     if !parent_flag
    #       groups << group
    #     end
    #   end

    #   capture_haml {
    #     haml_tag 'div.groups' do
    #       groups.each do |g|
    #         haml_tag 'a.group', g.name, :href => 'javascript:;', :data => {:id => g.id.to_s}
    #       end
    #     end
    #   }
    # end

    def user_groups_tag(user)
      groups = user.joined_group_tree_nodes.map { |g|
        g.self_and_ancestors
      }.flatten.uniq.sort { |a, b|
        a.lft <=> b.lft
      }

      capture_haml {
        haml_tag 'div.groups' do
          groups.each do |g|
            haml_tag 'a.group', g.name, :href => 'javascript:;', :data => {:id => g.id.to_s}
          end
        end
      }
    end

  private
    def _is_parent(ga, gb)
      return ga.lft < gb.lft && gb.rgt < ga.rgt
    end
  end

  include FeedHelper
  include TimeHelper
  include UserGroupHelper

  class ColorTransfer
    include Sass::Script

    def self.parse_color(s)
      r = s[1..2].to_i(16)
      g = s[3..4].to_i(16)
      b = s[5..6].to_i(16)

      c = Color.new [r, g, b]
      c.options = {}
      return c
    end

    def self.mix(s1, s2, i3)
      c1 = parse_color(s1)
      c2 = parse_color(s2)
      weight = Number.new(i3)

      c = Functions::EvaluationContext.new({}).mix(c1, c2, weight)
      c.options = {}
      return c
    end

    def self.invert(c1)
      c = Functions::EvaluationContext.new({}).invert(c1)
      c.options = {}
      return c
    end

    def self.grayscale(c1)
      c = Functions::EvaluationContext.new({}).grayscale(c1)
      c.options = {}
      return c
    end

    def self.darken(s1)
      c1 = parse_color(s1)

      amount = Number.new(10)
      c = Functions::EvaluationContext.new({}).darken(c1, amount)
      c.options = {}
      return c
    end
  end

end
