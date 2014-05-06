jQuery ->
  if jQuery('.page-file-show').length > 0
    jQuery('.page-file-show').delegate '.share-desc input', "click", (evt)->
      jQuery(this).select()

jQuery ->

  class PageFileUploader
    constructor: (@$elm, config) ->
      @uploader = new PartUpload(config)
      @uploader_item_class = PageFileUploaderItem

      @on_file_added = config.on_file_added || () ->
      @on_file_success = config.on_file_success || () ->
      @$button = config.button

      @items = [] 
      @setup()

    setup: ->
      @uploader.assign_button @$button

      @uploader.on 'fileAdded', (file) =>
        @add_file(file)
        @uploader.upload()
        @on_file_added(file)

      @uploader.on 'fileProgress', (file) =>
        file.uploader_item.sync_percent() if file.uploader_item

      @uploader.on 'fileSuccess', (file) =>
        @on_file_success(file)

    add_file: (file) =>
      uploader_item = new @uploader_item_class(@$elm, file).init()
      @items.push uploader_item

# -----------------

  class PageFileUploaderItem
    constructor: (@$uploader, @file) ->
      @$elm = @$uploader.find('.list .item.sample').clone().removeClass('sample').show()

    init: ->
      @$elm
        .find('.filename').html(@file.file_name).end()
        .find('.size').html(@file.size_str).end()
      @sync_percent()
      @file.uploader_item = @

      @$uploader.find('.list').append @$elm

      return @

    sync_percent: =>
      @$elm
        .find('.percent').html(@file.percent()).end()
        .find('.bar').css('width', @file.percent()).end()

    mark_success: (func)=>
      setTimeout =>
        @$elm
          .find('.page-progress').addClass('success').removeClass('active').end()
        func() if func
      , 600

  # 以上两个是基础类

  # 页面实现类
  class FileUploader
    constructor: (@$elm)->
      @$uploader = @$elm.find('.page-file-uploader')
      @$btn      = @$elm.find('a.btn.addfile')
      @$linked   = @$elm.find('.linked')
      @$input    = @$elm.find('input')
      @$foot     = @$elm.find('.foot')

      @multi = @$elm.data('multi') == 'multi'

      @uploader = new PageFileUploader @$uploader, {
        url: '/upload'
        multiple: @multi
        button: @$btn
        on_file_added: (file)=>
          jQuery(document).trigger 'mindpin-file-uploader:added', file
          if @multi
            @file_added_multi(file)
          else
            @file_added(file)
        on_file_success: (file)=>
          jQuery(document).trigger 'mindpin-file-uploader:success', file
          if @multi
            @file_success_multi(file)
          else
            @file_success(file)
      }

    file_added: (file)->
      @$linked.slideUp()
      @$foot.hide()

      $fitems = @$elm.find('.item').not('.sample')
      $fitems.first().remove() if $fitems.length > 1

    file_added_multi: (file)->


    file_success: (file)->
      @$input.val(file.file_entity_id)
      file.uploader_item.mark_success() if file.uploader_item

      setTimeout =>
        @$linked
          .slideDown()
          .find('.name').html(file.file_name)
        @$foot
          .show()
          .find('a span').html('重新上传')
      , 700

    file_success_multi: (file)->
      file.uploader_item.mark_success() if file.uploader_item


  jQuery('.page-form-file-uploader').each ->
    new FileUploader jQuery(this)

  jQuery(document).on 'mindpin-uploader:new-form-appended', (evt, form)->
    jQuery(form).find('.page-form-file-uploader').each ->
      new FileUploader jQuery(this)

# ---------------- 以上是文件上传组件的封装，保证在页面上可以一行代码调用。

# 但是不同的页面有特定的回调逻辑，分别写在下面。解耦之后不会太长。

# 课件上传页面：选择文件后，自动将文件名填写到课件标题栏
jQuery ->
  jQuery(document).on 'mindpin-file-uploader:added', (evt, file)->
    jQuery('input#course_ware_title').val(file.file_name)

# 资源文件页面：文件上传完毕后，自动触发资源创建逻辑
jQuery ->
  if jQuery('.page-files-index').length > 0
    jQuery(document).on 'mindpin-file-uploader:success', (evt, file)->
      setTimeout =>
        $elm = file.uploader_item.$elm
        $elm.fadeOut -> $elm.remove()

        dir = jQuery('.page-files-index').data('path')

        param_path = 
          if dir == '/'
          then "/#{file.file_name}" 
          else "#{dir}/#{file.file_name}"

        jQuery.ajax
          url : '/disk/create'
          type : 'POST'
          data :
            path : param_path
            file_entity_id : file.file_entity_id
          success : (res)->
            $tr = jQuery(res.html).find('tr').last()
            jQuery('.page-data-table.files').append($tr)
      , 700

  # 删除资源文件
    jQuery(document).delegate '.page-files-index .ops a.delete', 'click', ->
      if confirm('确定要删除吗？')
        $btn = jQuery(this)
        url = $btn.data('url')
        jQuery.ajax
          url: url
          type: 'delete'
          success: (res)=>
            $tr = $btn.closest('tr')
            $tr.fadeOut -> $tr.remove()


# ------------------------
  # 头像上传和裁剪

  if jQuery('.page-account-avatar').length > 0
    _upload_f = ->
      origin_width = null
      origin_height = null
      page_width  = null
      page_height = null
      $img = null
      $pimg = null

      update_preview = (c)->
        if page_width && parseInt(c.w) > 0
          rx = 180 / c.w;
          ry = 180 / c.h;

          $pimg.css
            width      : Math.round(rx * page_width)
            height     : Math.round(ry * page_height)
            marginLeft : - Math.round(rx * c.x)
            marginTop  : - Math.round(ry * c.y)

          jQuery('input[name=cx]').val c.x
          jQuery('input[name=cy]').val c.y
          jQuery('input[name=cw]').val c.w
          jQuery('input[name=ch]').val c.h


      jQuery('.page-account-avatar a.btn.cancel').on 'click', ->
        jQuery('.page-account-avatar .crop-avatars').slideDown(200)
        jQuery('.page-account-avatar .upload .btn').show()
        jQuery('.page-account-avatar .form').hide()
        jQuery('.page-file-uploader .item:not(.sample)').remove()

      jQuery('.page-account-avatar a.btn.submit').on 'click', ->
        jQuery('.page-account-avatar form').submit()


      jQuery(document).on 'mindpin-file-uploader:success', (evt, file)->
        $img = jQuery("<img src='#{file.file_entity_url}' />")
        $pimg = $img.clone()

        $img.hide().fadeIn()
        $img.on 'load', =>
          jQuery('.form-inputs .image').html $img
          jQuery('.form-inputs .preview').html $pimg

          jQuery('.page-account-avatar .crop-avatars').slideUp(200)
          jQuery('.page-account-avatar .upload .btn').hide()
          jQuery('.page-account-avatar .form').show()
        
          setTimeout =>
            origin_width  = jQuery('.form-inputs .image img').width()
            origin_height = jQuery('.form-inputs .image img').height()
            jQuery('input[name=origin_width]').val origin_width
            jQuery('input[name=origin_height]').val origin_height

            $img.css('max-width', '100%')

            $img.Jcrop
              bgColor: 'black'
              bgOpacity: 0.4
              setSelect: [ 0, 0, 180, 180 ]
              addClass: 'jcrop-dark'
              bgFade: true
              aspectRatio: 1
              onChange: update_preview
              onSelect: update_preview
            , ->
              this.ui.selection.addClass('jcrop-selection');
              bounds = this.getBounds()
              page_width = bounds[0]
              page_height = bounds[1]

              jQuery('input[name=page_width]').val page_width
              jQuery('input[name=page_height]').val page_height
              jQuery('input[name=cx]').val 0
              jQuery('input[name=cy]').val 0
              jQuery('input[name=cw]').val 180
              jQuery('input[name=ch]').val 180
          , 1

    _upload_f()