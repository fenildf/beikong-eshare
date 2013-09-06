# 设置选课人数上限的表单事件相关 INHOUSE
jQuery ->
  class CourseForm
    constructor: (@$form)->
      @setup()

    setup: ->
      that = @
      jQuery(@$form).on 'click', '#course_enable_apply_request_limit', ->
        $checkbox = jQuery(this)
        if $checkbox.is(':checked')
          that.show_limit()
        else
          that.hide_limit()

    show_limit: ->
      @$form.find('.limit-inputer').fadeIn(200).find('input').val('')

    hide_limit: ->
      @$form.find('.limit-inputer').fadeOut(200).find('input').val('')


  jQuery('.page-course-form form').each ->
    new CourseForm jQuery(this)


jQuery ->
  # 批准学生选课申请
  jQuery(document).on 'click', '.page-course-applies .students a.accept', ->
    user_id = jQuery(this).data('user-id')
    course_id = jQuery(this).data('course-id')

    jQuery.ajax
      url : "/manage/select_course_intents/accept"
      data : 
        user_id : user_id
        course_id : course_id
      type : 'put'
      success : (res)=>
        $new_tr = jQuery(res.html).find('tr.user')
        $old_tr = jQuery(this).closest('tr')
        $old_tr.after $new_tr
        $old_tr.remove()

        jQuery('.stat .c.accept_count').html(res.accept_count)
        jQuery('.stat .c.reject_count').html(res.reject_count)

  # 拒绝学生选课申请
  jQuery(document).on 'click', '.page-course-applies .students a.reject', ->
    user_id = jQuery(this).data('user-id')
    course_id = jQuery(this).data('course-id')

    jQuery.ajax
      url : "/manage/select_course_intents/reject"
      data : 
        user_id : user_id
        course_id : course_id
      type : 'put'
      success : (res)=>
        $new_tr = jQuery(res.html).find('tr.user')
        $old_tr = jQuery(this).closest('tr')
        $old_tr.after $new_tr
        $old_tr.remove()

        jQuery('.stat .c.accept_count').html(res.accept_count)
        jQuery('.stat .c.reject_count').html(res.reject_count)

  # 学生选课列表的折叠展开
  class OpenClose
    constructor: (@$tables)->
      @setup()
    setup: ->
      that = this
      @$tables.delegate 'td.open a.open', 'click', ->
        $table0 = jQuery(this).closest('table')
        $table1 = $table0.next('table')

        $table0.hide()
        $table1.show()

      @$tables.delegate 'td.close a.close', 'click', ->
        $table1 = jQuery(this).closest('table')
        $table0 = $table1.prev('table')

        $table1.hide()
        $table0.show()

  jQuery('.page-student-select-course-intent-form .courses-tables').each ->
    new OpenClose jQuery(this)


# 新版选课（三志愿）
jQuery ->
  class CourseSel
    constructor: (@$tables)->
      @setup()
    setup: ->
      that = this

      @$tables.delegate 'td input[type=radio]', 'change', ->
        # 让同一横排的不可点击
        $radio = jQuery(this)
        $td = $radio.closest('td')
        $td
          .find('input[type=radio]').prop('checked', false).end()
        
        jQuery('table td .int').removeClass('sel')

        $radio.prop('checked', true)

        that.set_form_value()

    set_form_value: ->
      $first = jQuery('input:checked[type=radio][name=first]')
      $second = jQuery('input:checked[type=radio][name=second]')
      $third = jQuery('input:checked[type=radio][name=third]')

      @set_value('first', $first)
      @set_value('second', $second)
      @set_value('third', $third)

    set_value: (flag, $radio)->
      $intent = jQuery(".result .intent.#{flag}")

      if $radio.length > 0
        $radio.closest('.int').addClass('sel')
        $intent.find(".r").html $radio.data('course-name')
        $intent.effect("highlight", {}, 400)

        jQuery("input[name=#{flag}_intent]").val $radio.data('course-id')
      else
        $intent.find(".r").html '未选择'
        jQuery("input[name=#{flag}_intent]").val ''

  jQuery('.page-student-select-course-intent-form .courses-tables').each ->
    new CourseSel jQuery(this)

# 新版选课（单志愿）
jQuery ->
  class CourseSelOne
    constructor: (@$tables)->
      @setup()
    setup: ->
      that = this
      
      @$tables.delegate 'td a.do-select', 'click', ->
        course_id = jQuery(this).data('id')
        $table = jQuery(this).closest('table')
        jQuery.ajax
          url: '/select_course_intents/save_one'
          type: 'POST'
          data:
            course_id: course_id
          success: (res)->
            $html = jQuery(res.html)
            # 标签
            $table.find('td.approved').html $html.find('td.approved').html()
            # 按钮
            $table.find('td.ops').html $html.find('td.ops').html()

      @$tables.delegate 'td a.do-unselect', 'click', ->
        if confirm('确定要撤销这个志愿吗？')
          course_id = jQuery(this).data('id')
          $table = jQuery(this).closest('table')
          jQuery.ajax
            url: '/select_course_intents/remove_one'
            type: 'DELETE'
            data:
              course_id: course_id
            success: (res)->
              $html = jQuery(res.html)
              # 标签
              $table.find('td.approved').html $html.find('td.approved').html()
              # 按钮
              $table.find('td.ops').html $html.find('td.ops').html()



  jQuery('.page-student-select-course-intent-form .courses-tables').each ->
    new CourseSelOne jQuery(this)

# 给课程增加任课老师
jQuery ->
  class TeacherSelector
    constructor: (@$button)->
      @$overlay = jQuery('.page-teacher-selector-overlay')
      @$selector = jQuery('.page-teacher-selector')
      @setup()

      @init_selector()

    setup: ->
      @$button.on 'click', =>
        @open()

      @$selector.find('a.btn.close').on 'click', =>
        @close()        

      @$overlay.on 'click', =>
        @close()      

    open: ->
      @$overlay.fadeIn(300)
      @$selector.css
        right: '-70%'
        opacity: 0
      .show()
      .animate
        right: 0
        opacity: 1
      , 300

    close: ->
      @$overlay.fadeOut(300)
      @$selector.css
        right: 0
        opacity: 1
      .animate {
        right: '-70%'
        opacity: 0
      }, 300, => 
        @$selector.hide()

    init_selector: ->
      that = this
      @$selector.delegate '.teacher:not(.creator) input[type=checkbox]', 'change', ->
        checked = jQuery(this).prop('checked')
        user_id = jQuery(this).closest('.teacher').data('id')

        if checked
          that.select(user_id)
        else
          that.unselect(user_id)
    
    _get_selector_teacher: (user_id)->
      @$selector.find(".teachers .teacher:not(.creator)[data-id=#{user_id}]")

    _get_result_teacher: (user_id)->
      @$selector.find(".results .teacher[data-id=#{user_id}]")

    select: (user_id)->
      $teacher = @_get_selector_teacher(user_id)
      $teacher.addClass('selected')

      @$selector.find('.results')
        .append jQuery("<div class='teacher' data-id=#{user_id}>#{$teacher.data('name')}</div>")

      @recount()

    unselect: (user_id)->
      $teacher = @_get_selector_teacher(user_id)
      $teacher.removeClass('selected')

      @_get_result_teacher(user_id).remove()

      @recount()

    recount: ->
      user_ids = []
      user_names = []
      @$selector.find(".teachers .teacher:not(.creator).selected").each ->
        user_ids.push jQuery(this).data('id')
        user_names.push jQuery(this).data('name')
      
      jQuery('.form-inputs .teachers span')
        .html if user_names.length > 0 then user_names.join('，') else '无'
      jQuery('.form-inputs .teachers input.teacher_ids').val user_ids.join(',')

      @$selector.find('span.count').html user_ids.length + 1

  jQuery('.page-course-form form .teachers a.add').each ->
    new TeacherSelector jQuery(this)