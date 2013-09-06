jQuery ->
  class CourseWareChapterSelector
    constructor: (@form)->
      @init()

    init: ->
      @$course_select = @form.find('select.course-id')
      @$chapter_select = @form.find('select.chapter-id')

      @$course_select.change =>
        course_id = @$course_select.val()
        if course_id == '0'
          @hide_chapter()
        else
          @show_chapter(course_id)

      @form.delegate 'select.chapter-id', 'change', =>
        chapter_id = @$course_select.val()
        if chapter_id == '0'
          @form.find('.datas').slideUp()
        else
          @form.find('.datas').slideDown()

    show_chapter: (course_id)->
      jQuery.ajax
        url: '/manage/course_wares/get_select_widget'
        data: 
          'course_id': course_id
        success: (res)=>
          if res.count > 0
            $new_chapter_select = jQuery(res.html)
          else
            $new_chapter_select = jQuery('<div>课程下没有章节</div>')
            @form.find('.datas').slideUp()

          @$chapter_select.after($new_chapter_select).remove()
          @$chapter_select = $new_chapter_select
          @form.find('.s-chapter').show()

    hide_chapter: ->
      @form.find('.s-chapter').hide()
      @form.find('.datas').slideUp()




  new CourseWareChapterSelector jQuery('.page-course-ware-form form')