jQuery ->
  if jQuery('.page-courses-index').length > 0
    jQuery('.page-courses-index')
      .delegate '.categories-select select', 'change', (evt)->
        value = jQuery(this).val()
        if value == 0
          window.location.href = "/courses"
        else
          window.location.href = "/courses?category_id=#{value}"