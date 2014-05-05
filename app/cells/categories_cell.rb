class CategoriesCell < Cell::Rails
  def list(opts = {})
    @categories = opts[:categories]
    render
  end

  def table(opts = {})
    @categories = opts[:categories]
    render
  end
end