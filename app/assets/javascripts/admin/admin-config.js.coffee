jQuery ->
  jQuery('.page-admin-auth-image-setting a.default').click (evt)->
    if confirm '确定恢复登录图片为默认值吗？'
      $form = jQuery(this).closest('form')
      $form.find('input[name=default]').val true
      $form.submit()