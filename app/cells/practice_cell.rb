class PracticeCell < Cell::Rails
  helper :application

  def info(opts = {})
    @practice = opts[:practice]
    render
  end
end