class DiskCell < Cell::Rails
  helper :application

  def file_table(opts = {})
    @media_resources = opts[:media_resources]
    render
  end
end