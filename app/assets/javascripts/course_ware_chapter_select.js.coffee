jQuery ->
  class CourseWareChapterSelector
    constructor: (@form)->
      if @form.length > 0
        @init()

    init: ->
      @$course_select = @form.find('select.course-id')
      @$chapter_select = @form.find('select.chapter-id')

      @course_change()
      @$course_select.change => @course_change()

      @form.delegate 'select.chapter-id', 'change', => @chapter_change()


    course_change: ->
      course_id = @$course_select.val()
      if course_id == '0' || !course_id?
        @hide_chapter()
      else
        @show_chapter(course_id)

    chapter_change: ->
      chapter_id = @$chapter_select.val()
      if chapter_id == '0' || !chapter_id?
        @form.find('.datas').slideUp()
      else
        @form.find('.datas').slideDown()

    show_chapter: (course_id)->
      data_chapter_id = @form.find('.chapter-select').data('chapter-id')

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

          $new_chapter_select
            .find("option[value=#{data_chapter_id}]")
            .attr('selected', 'selected')

          @$chapter_select.after($new_chapter_select).remove()
          @$chapter_select = $new_chapter_select
          @form.find('.s-chapter').show()
          @chapter_change()

    hide_chapter: ->
      @form.find('.s-chapter').hide()
      @form.find('.datas').slideUp()


  new CourseWareChapterSelector jQuery('.page-course-ware-form form')
  new CourseWareChapterSelector jQuery('.page-manage-practice-new form')