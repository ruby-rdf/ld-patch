# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/spec/format'

describe LD::Patch::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {LD::Patch::Format}
  end

  describe ".for" do
    formats = [
      :ldpatch,
      "etc/doap.ldp",
      {file_name:      'etc/doap.ldp'},
      {file_extension: 'ldp'},
      {content_type:   'text/ldpatch'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Format.for(arg)).to eq described_class
      end
    end
  end

  describe "#to_sym" do
    specify {expect(described_class.to_sym).to eq :ldpatch}
  end

  describe ".cli_commands", skip: ("TextMate OptionParser issues" if ENV['TM_SELECTED_FILE']) do
    require 'rdf/cli'
    let(:nt) {File.expand_path("../test-files/1triple.nt", __FILE__)}
    let(:patch) {File.expand_path("../test-files/add-1triple.ldpatch", __FILE__)}
    let(:patch_enc) {File.read(patch)} # Not encoded, since decode done in option parsing

    describe "#patch" do
      it "patches from file" do
        expect {RDF::CLI.exec(["patch", "serialize", nt], patch_file: patch)}.to write.to(:output)
      end
      it "patches from argument" do
        expect {RDF::CLI.exec(["patch", "serialize", nt], patch: patch_enc)}.to write.to(:output)
      end
    end
  end
end
