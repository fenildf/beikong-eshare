require "spec_helper"

describe MediaResourceDownload do
  let(:resource1) {FactoryGirl.create(:media_resource, :file)}
  let(:resource2) {FactoryGirl.create(:media_resource, :file)}

  describe "#download_id" do
    let(:decode)    {Base64.decode64(resource1.download_id)}
    let(:str)       {"#{resource1.creator.id},#{resource1.id}"}

    it "is consistent and uniq" do
      decode.should eq str
      resource1.download_id.should be_a String
      resource1.download_id.should_not eq resource2.download_id
    end
  end

  describe "#download_link" do
    subject {resource1.download_link}

    it {should eq "/download/#{resource1.download_id}"}
  end
end
