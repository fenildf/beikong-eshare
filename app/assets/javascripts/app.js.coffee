jQuery ->
  jQuery('.you-can-answer-only-once a').click ->
    href = jQuery(this).attr('href')
    $answer = jQuery(href) #.find('.tile-body')
    $answer.effect("highlight", {}, 2000)

jQuery('.btn').on 'dragstart', (evt) ->
  evt.preventDefault()

jQuery(document).delegate 'form a.do-submit', 'click', ->
  jQuery(this).closest('form').submit()