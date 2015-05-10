require 'spec_helper'

describe Her::WebMock::Model do
  let(:classic_model) { ClassicModel.new(id: 15, fake_attr: "Tissue") }
  let(:classic_model_with_parent) { ClassicModel.new(id: 16, fake_attr: "Tissue", classic_parent_model: classic_parent_model) }
  let(:classic_parent_model) { ClassicParentModel.new(id: 42) }

  context ".stub_all" do
    before do
      ClassicModel.stub_all([classic_model])
    end

    it "returns the stubs" do
      model = ClassicModel.all.fetch
      expect(model.size).to eq(1)

      model = model.first
      expect(model.fake_attr).to eq("Tissue")
    end
  end

  context ".stub_find" do
    before do
      ClassicModel.stub_find(classic_model)
    end

    it "returns the stubs" do
      model = ClassicModel.find(15)
      expect(model).to_not be_nil
      expect(model.id).to eq(15)
      expect(model.fake_attr).to eq("Tissue")
    end

    context "with associations" do
      before do
        ClassicModel.stub_find(classic_model_with_parent)
      end

      it "returns the stubs" do
        model = ClassicModel.find(16)
        expect(model).to_not be_nil
        expect(model.id).to eq(16)
        expect(model.fake_attr).to eq("Tissue")

        parent_model = model.classic_parent_model
        expect(parent_model.id).to eq(42)
      end
    end
  end

  context ".stub_create" do
    subject(:model) { ClassicModel.new(classic_model.attributes.except(:id)) }

    context do
      before do
        ClassicModel.stub_create(classic_model)
      end

      it "returns the stubs" do
        model.save
        expect(model).to be_persisted
        expect(model.id).to eq(15)
        expect(model.fake_attr).to eq("Tissue")
      end
    end

    context "stub_related: true" do
      before do
        ClassicModel.stub_create(classic_model, stub_related: true)
      end

      it "returns the stubs" do
        model.save
        expect(model).to be_persisted
        expect(model.id).to eq(15)
        expect(model.fake_attr).to eq("Tissue")

        created_model = ClassicModel.find(15)
        expect(created_model).to_not be_nil
        expect(created_model.id).to eq(15)
        expect(created_model.fake_attr).to eq("Tissue")

        created_all = ClassicModel.all.fetch
        expect(created_all.size).to eq(1)

        created_all_model = created_all.first
        expect(created_all_model.fake_attr).to eq("Tissue")
      end
    end
  end
end
