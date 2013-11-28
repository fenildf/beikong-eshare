class GroupTree
  constructor: (@$elm, @group_detail)->
    @init_nano_scroller()

    @add_child_form = new AddChildForm jQuery('.group-add-child')
    @add_child_form.tree = @

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
      that.add_child_form.show_on($btn)

  select_group: ($group)->
    @$elm.find('.group').removeClass('active')
    $group.addClass('active')
    @group_detail.load $group
    @scroll_to $group

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
    $parent_group.find('> .children').append $child_group

    $toggle = $parent_group.find(' > .data i.toggle')

    if $toggle.hasClass('icon-plus-sign')
      @toggle $parent_group
    else
      $toggle.removeClass('icon-leaf').addClass('icon-minus-sign')

    @init_nano_scroller()

class AddChildForm
  constructor: (@$elm)->
    @$overflow = @$elm.find('.add-child-form-overflow')
    @$form = @$elm.find('.add-child-form')

    @bind_events()

  bind_events: ->
    that = @
    @$form.delegate 'a.close', 'click', (evt)->
      that.hide()

    @$form.delegate 'a.submit', 'click', (evt)->
      jQuery.ajax
        method: 'POST'
        url: '/admin/user_groups'
        data:
          parent_group_id:    that.parent_group_id
          parent_group_depth: that.parent_group_depth
          kind:               that.parent_group_kind
          name:               that.$form.find('input').val()
        success: (res)->
          $new_group = jQuery(res.html)
          that.tree.add_child_to that.$parent_group, $new_group

          that.hide()

  show_on: ($btn)->
    @$parent_group      = $btn.closest('.group')
    @parent_group_id    = @$parent_group.data('id')
    @parent_group_depth = @$parent_group.data('depth')
    @parent_group_kind  = @$parent_group.data('kind')

    offset = $btn.offset()

    @$overflow.fadeIn(200)
    @$form
      .css
        left: offset.left - 6
        top: offset.top - 6
      .fadeIn(200)

    @$form.find('input').val('')

  hide:->
    @$overflow.fadeOut(200)
    @$form.fadeOut(200)

class GroupDetail
  constructor: (@$elm)->
    @bind_events()

  bind_events: ->
    that = @
    @$elm.delegate '.head .name .node a', 'click', ->
      id = jQuery(this).data('id')
      $group = that.tree.$elm.find(".group[data-id=#{id}]")
      that.tree.select_group $group

  load: ($group)->
    @set_head $group
    @set_ops $group

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
      @$elm.find('a.delete').show()

jQuery ->
  group_detail = new GroupDetail jQuery('.page-admin-users .group-detail').first()
  group_tree = new GroupTree jQuery('.page-admin-users .group-tree').first(), group_detail
  group_detail.tree = group_tree