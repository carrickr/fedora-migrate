require 'spec_helper'

describe FedoraMigrate::DatastreamMover do
  let(:mover) do
    described_class.new(
      FedoraMigrate.source.connection.find("sufia:rb68xc089").datastreams["content"],
      ExampleModel::VersionedContent.create.attached_files["content"]
    )
  end

  let(:application_mover) do
    described_class.new(
      FedoraMigrate.source.connection.find("sufia:rb68xc089").datastreams["content"],
      ExampleModel::VersionedContent.create.attached_files["content"],
      application_creates_versions: true
    )
  end

  it "calls the before and after hooks when migrating" do
    expect(mover).to receive(:before_datastream_migration)
    expect(mover).to receive(:after_datastream_migration)
    mover.migrate
  end

  context "with migrating versions" do
    subject do
      mover.migrate
      mover.target
    end
    it "migrates all versions" do
      expect(subject.versions.all.count).to eql 3
    end
    it "preserves metadata" do
      expect(subject.mime_type).to eql "image/png"
      expect(subject.original_name).to eql "world.png"
    end
    context "and the application creates the versions" do
      subject do
        application_mover.migrate
        application_mover.target
      end
      it "FedoraMigrate creates no versions" do
        expect(subject.versions.count).to eql 0
      end
    end
  end

  context "without migrating versions" do
    subject do
      mover.versionable = false
      mover.migrate
      mover.target
    end
    it "migrates only the most recent version" do
      expect(subject.versions.count).to eql 0
      expect(subject.content).not_to be_nil
    end
    it "preserves metadata" do
      expect(subject.mime_type).to eql "image/png"
      expect(subject.original_name).to eql "world.png"
    end
  end
end
