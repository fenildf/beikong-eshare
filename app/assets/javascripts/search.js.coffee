# 次级搜索栏
jQuery ->
  jQuery('.page-filter input[name=q]').keydown (evt)->
    if evt.keyCode is 13
      q = jQuery(this).val()
      location.href = jQuery(this).data('href') + "?q=#{q}"

  jQuery('.page-filter a.do-search').click (evt)->
    $input = jQuery(this).parent().find('input[name=q]')
    q = $input.val()
    location.href = $input.data('href') + "?q=#{q}"


# jQuery ->
#   search = ($input)->
#     q = jQuery.trim $input.val()
#     if q != ''
#       location.href = "/search/#{q}"

#   $input = jQuery('.page-search-bar input[name=q]')
#   $input.keydown (evt)=>
#     if evt.keyCode == 13
#       search($input)

#   jQuery('.page-search-bar .do-search').on 'click', ->
#     search($input)