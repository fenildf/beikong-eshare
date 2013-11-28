class GroupTreeCell < Cell::Rails
  helper :application

  def node(opts = {})
    @node = opts[:node]
    @depth = opts[:depth] || 0
    render
  end

  def show(opts = {})
    @node = opts[:node]
    render
  end
end