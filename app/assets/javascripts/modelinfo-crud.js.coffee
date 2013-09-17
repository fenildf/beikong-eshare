class ModelInfoCrud
  constructor: (@$pblock_modelinfo)->
    @$edit_btn = @$pblock_modelinfo.find('.btns a.edit')
    @$baseinfo = @$pblock_modelinfo.find('.baseinfo')

    @setup()

  setup: ->
    @$edit_btn.on 'click', =>
      url = @$edit_btn.data('url')
      jQuery.ajax
        url: url
        method: 'GET'
        success: (res)=>
          @show_form(res)

    @$pblock_modelinfo.delegate '.edit-form a.btn.cancel', 'click', =>
      @hide_form()

    @$pblock_modelinfo.delegate 'form a.submit', 'click', ->
      jQuery(this).closest('form').submit()

    @$pblock_modelinfo.delegate 'form', 'ajax:success', (evt, res)=>
      @hide_form =>
        if res.html
          $new_info = jQuery(res.html).find('.infodata')
          @$pblock_modelinfo.find('.infodata')
            .after($new_info)
            .remove()

          $new_info.closest('.pblock').effect "highlight", 2000
          jQuery(document).trigger('mindpin:new-content-appended')

  show_form: (res)->
    $form = jQuery("<div>#{res.html}</div>").addClass('edit-form')
    @$baseinfo
      .after($form.hide())
      .slideUp()

    setTimeout =>
      $form.slideDown()
      jQuery(document).trigger 'mindpin-uploader:new-form-appended', $form
      jQuery(document).focus()
    , 1

  hide_form: (func)->
    $form = @$pblock_modelinfo.find('.edit-form')
    $form.slideUp -> $form.remove()
    @$baseinfo.slideDown 'normal', =>
      func() if func

jQuery ->
  jQuery('.pblock.modelinfo').each ->
    new ModelInfoCrud jQuery(this)