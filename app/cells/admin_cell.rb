class AdminCell < Cell::Rails
  helper :application

  def form_user_role_select(opts = {})
    @form_object = opts[:form_object]
    render
  end
end