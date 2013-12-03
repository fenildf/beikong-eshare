class GroupTreeCell < Cell::Rails
  helper :application

  def node(opts = {})
    @node = opts[:node]
    @depth = opts[:depth] || 0
    render
  end

  def show(opts = {})
    @node = opts[:node]
    @users = opts[:users]
    render
  end

  def user_selector(opts = {})
    render
  end
end