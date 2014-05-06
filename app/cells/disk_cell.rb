class DiskCell < Cell::Rails
  helper :application

  def file_table(opts = {})
    @media_resources = opts[:media_resources]
    render
  end

  def file_info(opts = {})
    @media_resource = opts[:media_resource]
    @user = opts[:user]
    render
  end
end