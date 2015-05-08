require 'spec_helper'

describe Her::WebMock::Model do
  context ".stub_all" do
    before do
      ClassicModel.stub_all([ClassicModel.new(fake_attr: "Y'all got issues")])
    end

    it "returns the stubs" do
      response = ClassicModel.all.fetch
      expect(response.size).to eq(1)

      response = response.first
      expect(response.fake_attr).to eq("Y'all got issues")
    end
  end

  context ".stub_find" do
    before do
      ClassicModel.stub_find(ClassicModel.new(id: 15, fake_attr: "Tissue"))
    end

    it "returns the stubs" do
      response = ClassicModel.find(15)
      expect(response).to_not be_nil
      expect(response.id).to eq(15)
      expect(response.fake_attr).to eq("Tissue")
    end
  end
end
