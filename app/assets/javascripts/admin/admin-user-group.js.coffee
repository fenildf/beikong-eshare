class GroupTree
  constructor: (@$elm, @group_detail)->
    @init_nano_scroller()

    @form_widget = new FormWidget jQuery('.group-forms')
    @form_widget.tree = @

    @bind_events()

  bind_events: ->
    that = @

    @$elm.delegate '.data', 'click', (evt)->
      $group = jQuery(this).closest('.group')
      node_id = $group.data('id')

      that.select_group $group

    @$elm.delegate 'i.toggle', 'click', (evt)->
      $group = jQuery(this).closest('.group')
      that.toggle $group

    @$elm.delegate 'a.add-child', 'click', (evt)->
      $btn = jQuery(this)
      that.form_widget.show_new_form_on($btn)

    @$elm.delegate 'a.edit', 'click', (evt)->
      $btn = jQuery(this)
      that.form_widget.show_edit_form_on($btn)

  select_group: ($group)->
    @$current_group = $group
    @$elm.find('.group').removeClass('active')
    $group.addClass('active')
    @group_detail.load $group
    @scroll_to $group
    $group.removeClass('new')

  toggle: ($group)->
    $toggle = $group.find(' > .data i.toggle')
    $children = $group.find(' > .children')
    
    if $toggle.hasClass('icon-minus-sign')
      $toggle.removeClass('icon-minus-sign').addClass('icon-plus-sign')
      $children.slideUp 200, =>
        @init_nano_scroller()
    else if $toggle.hasClass('icon-plus-sign')
      $toggle.removeClass('icon-plus-sign').addClass('icon-minus-sign')
      $children.slideDown 200, =>
        @init_nano_scroller()

  scroll_to: ($group)->
    scroll_top = jQuery('.group-tree .nano .nano-content').scrollTop()
    height = jQuery('.group-tree .nano .nano-content').height()
    scroll_bottom = scroll_top + height

    group_top = $group.position().top + scroll_top
    group_height = $group.find('.data').height()
    group_bottom = group_top + group_height

    if group_bottom > scroll_bottom
      new_top = scroll_top + group_bottom - scroll_bottom + 20
      jQuery('.group-tree .nano .nano-content').animate
        scrollTop: new_top
      , 200

    if group_top < scroll_top
      jQuery('.group-tree .nano .nano-content').animate
        scrollTop: group_top
      , 200



  init_nano_scroller: ->
    setTimeout =>
      @scroller = jQuery('.group-tree .nano').nanoScroller
        contentClass: 'nano-content'
        alwaysVisible: true
    , 1

  add_child_to: ($parent_group, $child_group)->
    $child_group.addClass('new')
    $parent_group.find('> .children').append $child_group

    $child_group.hide().fadeIn 200
    
    @refresh_group_icon $parent_group
    @init_nano_scroller()

    @select_group $parent_group

  remove_group: ($group)->
    $prev = $group.prev('.group')
    $next = $group.next('.group')
    $parent = $group.parents('.group').first()

    $g = 
      if $prev.length > 0 then $prev
      else if $next.length > 0 then $next
      else $parent


    $group.fadeOut 200, =>
      $group.remove()
      @refresh_group_icon $parent
      @select_group $g

  refresh_group_icon: ($group)->
    $toggle = $group.find(' > .data i.toggle')

    # 如果已经没有子节点，则改图标为叶子
    if $group.find('.children .group').length == 0
      $toggle
        .removeClass('icon-minus-sign')
        .removeClass('icon-plus-sign')
        .addClass('icon-leaf')

    # 如果有子节点，则改图标为展开（减号），且展开
    else
      $toggle
        .removeClass('icon-leaf')
        .addClass('icon-minus-sign')

      $group.find('.children').slideDown 200, =>
        @init_nano_scroller()


class FormWidget
  constructor: (@$elm)->
    @$overlay = @$elm.find('.form-overlay')
    @$new_form = @$elm.find('.add-child-form')
    @$edit_form = @$elm.find('.edit-form')

    @$add_user_form = jQuery('.page-user-selector')

    @bind_events()

  bind_events: ->
    that = @
    @$new_form.delegate 'a.close', 'click', (evt)->
      that.hide()

    @$edit_form.delegate 'a.close', 'click', (evt)->
      that.hide()

    @$new_form.delegate 'a.submit', 'click', (evt)->
      that.submit_new_form()

    @$new_form.find('input').keypress (evt)->
      if evt.which == 13
        that.submit_new_form()

    @$edit_form.delegate 'a.submit', 'click', (evt)->
      that.submit_edit_form()

    @$edit_form.find('input').keypress (evt)->
      if evt.which == 13
        that.submit_edit_form()

    @$overlay.on 'click', (evt)->
      that.hide()

    # ------------- add-user-form

    jQuery(document).delegate '.group-detail .add-user', 'click', (evt)->
      that.show_add_user_form()

    @$add_user_form.delegate '.btns .btn.close', 'click', (evt)->
      that.hide()

    @$add_user_form.delegate '.data-from-group-users table th.select input', 'change', (evt)->
      if jQuery(this).prop('checked')
        that.$add_user_form.find('table td.select input').each ->
          jQuery(this).prop('checked', true)
          that.check_user_tr jQuery(this).closest('tr'), true

      else
        that.$add_user_form.find('table td.select input').each ->
          jQuery(this).prop('checked', false)
          that.check_user_tr jQuery(this).closest('tr'), false

      that.do_change_group_user()

    @$add_user_form.delegate '.data-from-group-users table td.select input', 'change', (evt)->
      if jQuery(this).prop('checked')
        that.check_user_tr jQuery(this).closest('tr'), true
      else
        that.check_user_tr jQuery(this).closest('tr'), false

      that.do_change_group_user()

  check_user_tr: ($tr, checked)->
    id = $tr.data('id')
    name = $tr.data('name')
    
    if checked
      $tr.addClass('checked')
      @$add_user_form.find('.data-to-group-users')
        .append jQuery("<div class='usr'>#{name}</div>").attr('data-id', id)
    else
      $tr.removeClass('checked')
      @$add_user_form.find(".data-to-group-users .usr[data-id=#{id}]").remove()

  do_change_group_user: ->
    user_ids = []
    @$add_user_form.find(".data-to-group-users .usr").each ->
      user_ids.push jQuery(this).data('id')

    group_id = @tree.$current_group.data('id')

    jQuery.ajax
      method: 'PUT'
      url: "/admin/user_groups/#{group_id}/do_change_users"
      data:
        user_ids: user_ids
      success: (res)->
        console.log res


  submit_new_form: ->
    jQuery.ajax
      method: 'POST'
      url: '/admin/user_groups'
      data:
        parent_group_id:    @parent_group_id
        parent_group_depth: @parent_group_depth
        kind:               @parent_group_kind
        name:               @$new_form.find('input').val()
      success: (res)=>
        $new_group = jQuery(res.html)
        @tree.add_child_to @$parent_group, $new_group

        @hide()

  submit_edit_form: ->
      jQuery.ajax
        method: 'PUT'
        url: "/admin/user_groups/#{@edit_group_id}"
        data:
          name: @$edit_form.find('input').val()
        success: (res)=>
          @$edit_group.find('> .data .name').html res.name
          @$edit_group.data('name', res.name)

          @hide()

  show_new_form_on: ($btn)->
    @$parent_group      = $btn.closest('.group')
    @parent_group_id    = @$parent_group.data('id')
    @parent_group_depth = @$parent_group.data('depth')
    @parent_group_kind  = @$parent_group.data('kind')

    offset = $btn.offset()

    @$overlay.fadeIn(200)
    @$new_form
      .css
        left: offset.left - 8
        top: offset.top - 8
      .fadeIn(200)

    @$new_form.find('input').val('').focus()

  show_edit_form_on: ($btn)->
    @$edit_group      = $btn.closest('.group')
    @edit_group_id    = @$edit_group.data('id')

    offset = $btn.offset()

    @$overlay.fadeIn(200)
    @$edit_form
      .css
        left: offset.left - 8
        top: offset.top - 8
      .fadeIn(200)

    @$edit_form.find('input').val(@$edit_group.data('name')).select()

  show_add_user_form: ->
    @$add_user_form.find('.data-from-group-users').html('正在载入……')
    
    id   = @tree.$current_group.data('id')
    kind = @tree.$current_group.data('kind')

    from_id = @$add_user_form.find('.group.active').first().data('id')

    jQuery.ajax
      method: 'GET'
      url: "/admin/user_groups/#{id}/add_user_form"
      data:
        from: from_id
        kind: kind
      success: (res)=>
        console.log res
        $new_table = jQuery(res.html).find('.data-from-group-users table')
        $new_table.find('th.select .th-inner').html("<input type=checkbox />")
        console.log $new_table
        @$add_user_form.find('.data-from-group-users').html $new_table

    @$overlay.fadeIn(200)
    @$add_user_form.css
      right: '-70%'
      opacity: 0
    .show()
    .animate
      right: 0
      opacity: 1
    , 200

  hide:->
    @$overlay.fadeOut(200)
    @$new_form.fadeOut(200)
    @$edit_form.fadeOut(200)

    @$add_user_form.css
      right: 0
      opacity: 1
    .animate {
      right: '-70%'
      opacity: 0
    }, 300, => 
      @$add_user_form.hide()

class GroupDetail
  constructor: (@$elm)->
    @bind_events()

  bind_events: ->
    that = @
    @$elm.delegate '.head .name .node a', 'click', ->
      id = jQuery(this).data('id')
      $group = that.tree.$elm.find(".group[data-id=#{id}]")
      that.tree.select_group $group

    @$elm.delegate '.head .ops a.delete', 'click', ->
      # if xxx
        # 组里有人，还不能删

      if confirm "确定要删除 “#{that.$current_group.data('name')}” 吗？"
        jQuery.ajax
          method: 'DELETE'
          url: "/admin/user_groups/#{that.$current_group.data('id')}"
          success: ->
            that.tree.remove_group that.$current_group

    @$elm.delegate '.detail .children .child', 'click', ->
      id = jQuery(this).data('id')
      $group = that.tree.$elm.find(".group[data-id=#{id}]")
      that.tree.select_group $group

    @$elm.delegate '.paginate li:not(.active) a', 'click', (evt)->
      evt.preventDefault()

      url = jQuery(this).prop('href')
      match = url.match(/page=(\d+)/)
      page = if match == null then 1 else match[1]

      that.load that.$current_group, page

  load: ($group, page)->
    @set_head $group
    @set_ops $group

    @request_id = Math.random() + ""

    if @$current_group != $group
      @$current_group = $group
      @change_page = false
      @$elm.find('.detail').html '<div class="loading">正在载入……</div>'
    else
      @change_page = true

    jQuery.ajax
      method: 'GET'
      url: "/admin/user_groups/#{$group.data('id')}"
      data:
        rid: @request_id
        kind: $group.data('kind')
        page: page
      success: (res)=>
        if res.rid == @request_id
          if @change_page
            $new_usrs = jQuery("<div>#{res.html}</div>").find('.usrs')
            $old_usrs = @$elm.find('.detail .usrs')
            $old_usrs.after($new_usrs)
            $old_usrs.remove()
          else
            @$elm.find('.detail').html res.html

          jQuery(document).trigger 'group:data-loaded'



  set_head: ($group)->
    str = "<span class='node'>#{$group.data('name')}</span>"

    $group.parents('.group').each ->
      $g = jQuery(this)
      str = "<span class='node'>
              <a href='javascript:;' data-id=#{$g.data('id')}>#{$g.data('name')}</a>
              <i class='icon-chevron-right'/>
             </span>" + str

    @$elm.find('.head .name').html(str)

  set_ops: ($group)->
    if $group.data('id') == 0
      @$elm.find('a.delete').hide()
    else
      if $group.find('.children .group').length == 0
        @$elm.find('a.delete').show()
      else
        @$elm.find('a.delete').hide()

jQuery ->
  return if jQuery('.page-admin-users').length == 0

  group_detail = new GroupDetail jQuery('.page-admin-users .group-detail').first()
  group_tree = new GroupTree jQuery('.page-admin-users .group-tree').first(), group_detail
  group_detail.tree = group_tree

  group_tree.select_group group_tree.$elm.find(".group[data-id=-1]")

  table_resize = =>
    h = jQuery(window).height() - 31 - 71 - jQuery('.detail .chds').height()
    jQuery('.detail .usrs').height(h).fadeIn(100)

  table_resize()

  jQuery(window).resize ->
    table_resize()

  jQuery(document).on 'group:data-loaded', ->
    table_resize()