class Contact
  constructor: (@$elm)->
    @id   = @$elm.data("id")
    @name = @$elm.data("name")
    @$elm.data("contact", @)

class ChatBar
  constructor: (@$elm, @client)->
    @user =
      id:   @$elm.data("user-id")
      name: @$elm.data("user-name")

    @$contacts     = @$elm.find(".contacts")
    @$users        = @$contacts.find(".user")
    @subscriptions = []

    @attach_listeners()
    @status("online")

  attach_listeners: ->
    that = @
    @$users.on "click", (evt)->
      that.chatbox.$elm.fadeIn()
      that.chatbox.set_receiver(jQuery(this))

    jQuery(window).on "unload", =>
      @status("offline")
      @client.disconnect()

    @client.subscribe "/user_status", (obj)->
      console.log "#{obj.name}上线啦！" if obj.status == "online"
      console.log "#{obj.name}下线啦！" if obj.status == "offline"


  connect_chatbox: (chatbox)->
    @chatbox = chatbox

  status: (status)->
    @client.publish("/user_status", jQuery.extend(@user, {status: status}))

  start_chat: ->
    return if @subscriptions.some((sub)=> sub.channel == @chatbox.channel)

    subscription = @client.subscribe @chatbox.channel, (obj)=>
      if obj.sender.id == @chatbox.receiver.id || obj.sender.id == @user.id
        @chatbox.append_message(obj)
        @chatbox.scroll()

    subscription.channel = @chatbox.channel
    @subscriptions.push subscription

class ChatBox
  constructor: (@chatbar)->
    @chatbar.connect_chatbox(@)
    @sender    = @chatbar.user
    @$elm      = @chatbar.$elm.find(".chat-box")
    @$input    = @$elm.find(".inputer textarea.ipt")
    @$close    = @$elm.find(".close")
    @$chatlog  = @$elm.find(".chatlog")
    @$button   = @$elm.find(".inputer .btn")
    @$name     = @$elm.find(".contact .name")

    @attach_listeners()

  attach_listeners: ->
    @$close.on "click", =>
      @$elm.fadeOut()

    @$input.on "keypress", (evt)=>
      if evt.charCode == 13 && evt.ctrlKey
        evt.preventDefault()
        @send_message()

    @$button.on "click", =>
      @send_message()

  append_message: (obj)->
    $message = jQuery(
      "<div class='message'>" +
        "<span class='sender'>#{obj.sender.name}</span>" +
        "<span>:</span>" +
        "<span class='content'>#{obj.message}</span>" +
      "</div>"
    )
    @$log.append $message

  clear_input: ->
    @$input.val("")

  scroll: ->
    height = @$chatlog[0].scrollHeight
    @$chatlog.scrollTop(height);

  set_receiver: ($elm)->
    @receiver = $elm.data("contact") || new Contact($elm)
    @request_chatlog() if !@receiver.started
    @set_log(@receiver.$log) if @receiver.started
    @set_channel()
    @$name.html(@receiver.name)
    @chatbar.start_chat()

  set_log: ($log)->
    @$log = $log
    @$chatlog.html @$log

  set_channel: ->
    user1 = if @receiver.id > @sender.id then @sender else @receiver
    user2 = if user1 == @receiver then @sender else @receiver

    @channel = "/chat_#{user1.id}_#{user2.id}"

  send_message: ->
    message = @$input.val()
    return if message.length == 0
    @chatbar.client.publish(@channel, {sender: @sender, message: message, channel: @channel})
    @persist_message(message)
    @clear_input()

  request_chatlog: ->
    jQuery.ajax
      url:  "/short_messages/chatlog"
      type: "get"
      data:
        contact_user_id: @receiver.id
      success: (res)=>
        @receiver.$log = jQuery(res)
        @receiver.started = true
        @set_log(@receiver.$log)

  persist_message: (message)->
    jQuery.ajax
      url:  "/short_messages"
      type: "post"
      data:
        contact_user_id: @receiver.id
        content: message

jQuery(document).on "faye_ready", (evt, client)->
  window.chatbar = new ChatBar(jQuery(".page-chat-bar"), client)
  window.chatbox = new ChatBox(chatbar)

  console.log chatbar, chatbox

jQuery ->
  host = window.location.host.split(':')[0]
  faye_server_url = "http://#{host}:8080/faye"

  if jQuery(".page-chat-bar").length > 0
    jQuery.getScript "#{faye_server_url}/client.js",
    =>
      faye_client = new Faye.Client(faye_server_url)
      faye_client.disable("autodisconnect")
      jQuery(document).trigger("faye_ready", faye_client)
    =>
      console.log "无法连接到Faye即时聊天服务器"

