jQuery ->

  class PageFileUploader
    constructor: (@$elm, config) ->
      @uploader = new PartUpload(config)
      @uploader_item_class = PageFileUploaderItem

      @on_file_success = config.on_file_success || () ->
      @$button = config.button

      @items = [] 
      @setup()

    setup: ->
      @uploader.assign_button @$button

      @uploader.on 'fileAdded', (file) =>
        @add_file(file)
        @uploader.upload()

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

    mark_success: =>
      setTimeout =>
        @$elm
          .find('.page-progress').addClass('success').removeClass('active').end()
      , 700

# ----------------------
  
  # 资源文件
  new PageFileUploader jQuery('.page-file-uploader'), {
    url : '/upload'
    multiple : true
    button : jQuery('a.media-resource-upload')
    on_file_success : (file) ->

      dir = jQuery('.page-files-index').data('path')
      if dir == '/'
        param_path = "/#{file.file_name}" 
      else 
        param_path = "#{dir}/#{file.file_name}"

      jQuery.ajax
        url : '/disk/create'
        type : 'POST'
        data :
          path : param_path
          file_entity_id : file.file_entity_id
        success : (res)->
          console.log res
          file.uploader_item.mark_success() if file.uploader_item

  }

# ----------------------

  # 作业附件
  new PageFileUploader jQuery('.page-file-uploader'), {
    url : '/upload'
    multiple : true
    button : jQuery('a.btn.homework-attach-upload')
    on_file_success : (file) ->
      $attaches = jQuery('.page-homework-new form .attaches')
      count = $attaches.data('count')

      $f_id   = jQuery("<input type='text' />")
                 .attr('name', "homework[homework_attaches_attributes][#{count}][file_entity_id]")
                 .val(file.file_entity_id)
      $f_name = jQuery("<input type='text' />")
                 .attr('name', "homework[homework_attaches_attributes][#{count}][name]")
                 .val(file.file_name)

      $attaches
        .append($f_id)
        .append($f_name)
        .data('count', count + 1)

      file.uploader_item.mark_success() if file.uploader_item
  }

# ----------------------

  # 作业提交
  new PageFileUploader jQuery('.page-file-uploader'), {
    url : '/upload'
    multiple : false
    button : jQuery('a.btn.homework-requirement-upload')
    on_file_success : (file) ->
      param_id = jQuery(file.input_target).closest('.item').data('id')

      jQuery.ajax
        url : "/homework_requirements/#{param_id}/upload"
        type : 'POST'
        data :
          'homework_upload[file_entity_id]' : file.file_entity_id
          'homework_upload[name]' : file.file_name
        success : (res) ->
          console.log res
          file.uploader_item.mark_success() if file.uploader_item

  }