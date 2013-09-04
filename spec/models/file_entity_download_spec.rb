require "spec_helper"

describe FileEntityDownload do
  describe ".from_download_id" do
    let(:resource1) {FactoryGirl.create :media_resource, :file}
    subject {FileEntity.from_download_id(resource1.download_id)}

    it {should be_a FileEntity}
    its(:media_resources) {should include resource1}
  end
end
