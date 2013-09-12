class ModelCounter
  constructor: (@$desc_elm)->
    @$count_elm = @$desc_elm.find('.count')
    @count = parseInt @$count_elm.html()

  changeto: (new_count)->
    if new_count
      return if new_count == @count
      @animate(new_count - @count)

      @count = new_count
      @$count_elm.html(@count)

  animate: (change)->
    if change > 0
      text = "+#{change}"
      topchange = -20
      klass = 'up'
    else
      text = change
      topchange = 20
      klass = 'down'

    offset = @$count_elm.offset()
    $change = jQuery("<div class='count-change'></div>")
      .addClass(klass)
      .html(text)
      .css
        left: offset.left
        top: offset.top
      .appendTo(jQuery('body'))

    $change.animate
      top: offset.top + topchange
      =>
        $change.fadeOut => $change.remove()

class TableNewForm
  constructor: (@$table_block_elm)->
    @$op      = @$table_block_elm.find('.op')
    @$new_btn = @$table_block_elm.find('a.btn.new')
    @$tbl     = @$table_block_elm.find('.tbl')
    @$table   = @$table_block_elm.find('table')
    @$js_dyn_table = @$table_block_elm.closest('.js-dyn-table')
    @$blankslate   = @$js_dyn_table.find('.blankslate')

    @model_counter = new ModelCounter @$op.find('.counter')

    @setup()

  setup: ->
    @$new_btn.on 'click', =>
      url = @$new_btn.data('url')
      jQuery.ajax
        url: url
        method: 'GET'
        success: (res)=>
          @show_form(res)

    @$table_block_elm.delegate 'input', 'keydown', (evt)->
      if evt.keyCode == 13
        evt.preventDefault()
        return false

    @$table_block_elm.delegate 'form a.cancel', 'click', =>
      @hide_form()

    @$table_block_elm.delegate 'form a.submit', 'click', ->
      jQuery(this).closest('form').submit()

    @$table_block_elm.delegate 'form', 'ajax:success', (evt, res)=>
      @deal_blank(res.count)

      @hide_form =>
        @model_counter.changeto(res.count)
        if res.html
          $new_tr = jQuery(res.html).find('tr').last()
          @$table.append($new_tr)
          jQuery('body').scrollTo($new_tr)
          $new_tr.find('td').effect "highlight", 2000

    @$table.on 'mindpin-table:line-removed', (evt, data)=>
      @deal_blank(data.count)
      @model_counter.changeto(data.count)

  deal_blank: (count)->
    console.log count
    count = @model_counter.count if typeof(count) == 'undefined'
    if count > 0
      @$js_dyn_table.removeClass('blank')
      @$blankslate.hide()
    else
      @$js_dyn_table.addClass('blank')
      @$blankslate.fadeIn()
      @$tbl.css('display', '')


  show_form: (res)->
    $form = jQuery("<div>#{res.html}</div>").addClass('new-form')
    @$op
      .after($form.hide())
      .slideUp()
    @$tbl.slideUp()

    setTimeout =>
      $form.slideDown()
      jQuery(document).trigger 'mindpin-uploader:new-form-appended', $form
    , 1

  hide_form: (func)->
    $form = @$table_block_elm.find('.new-form')
    $form.slideUp -> $form.remove()
    @$op.slideDown()

    if !@$js_dyn_table.hasClass('blank')
      @$tbl.slideDown 'normal', => 
        func() if func


jQuery ->
  jQuery('.pblock.table .new-line').each ->
    $table_block_elm = jQuery(this).closest('.pblock.table')
    new TableNewForm $table_block_elm