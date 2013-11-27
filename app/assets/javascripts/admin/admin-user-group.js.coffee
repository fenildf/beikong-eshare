class GroupTree
  constructor: (@$elm, @group_detail)->
    @bind_events()
    @init_nano_scroller()

  bind_events: ->
    that = @

    @$elm.delegate '.data', 'click', (evt)->
      $group = jQuery(this).closest('.group')
      node_id = $group.data('id')

      that.select_group $group

    @$elm.delegate 'i.toggle', 'click', (evt)->
      $group = jQuery(this).closest('.group')

      that.toggle $group      

  select_group: ($group)->
    @$elm.find('.group').removeClass('active')
    $group.addClass('active')

    @group_detail.set_head_name $group.data('name')

  toggle: ($group)->
    $toggle = $group.find(' > .data i.toggle')
    $children = $group.find(' > .children')
    
    if $toggle.hasClass('icon-minus-sign')
      $toggle.removeClass('icon-minus-sign').addClass('icon-plus-sign')
      $children.slideUp(200)
    else if $toggle.hasClass('icon-plus-sign')
      $toggle.removeClass('icon-plus-sign').addClass('icon-minus-sign')
      $children.slideDown(200)

  init_nano_scroller: ->
    jQuery('.group-tree .nano').nanoScroller
      contentClass: 'nano-content'
      alwaysVisible: true

class GroupDetail
  constructor: (@$elm)->

  set_head_name: (text)->
    @$elm.find('.head .name').html(text)

jQuery ->
  group_detail = new GroupDetail jQuery('.page-admin-users .group-detail').first()
  group_tree = new GroupTree jQuery('.page-admin-users .group-tree').first(), group_detail