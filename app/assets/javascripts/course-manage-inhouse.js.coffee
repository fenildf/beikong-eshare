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

  # # 拒绝学生选课申请
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



# 新版选课
jQuery ->
  class CourseSel
    constructor: (@$tables)->
      @setup()
    setup: ->
      that = this

      @$tables.delegate 'td input[type=radio]', 'change', ->
        console.log 1
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
