require_relative 'spec_helper'

describe Rhubarb::Email, "#deliver" do
  include Helpers
  include Mail::Matchers

  before(:each) do
    cleanse_live
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
  end

  before(:all) do
    Rhubarb::Email.parse_addresses(File.join(File.dirname(__FILE__), 'addresses.yaml'))

    js_archibus = <<ARCHIBUS
---
name: ARCHIBUS
outputs:
  foo:
    subject: "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
    message: >
      Attached are the reports that show the results and provide information on
      building/room records successfully updated and any error conditions found,
      if any, as a result of any Archibus files that were processed for the day.
    to:
    - SAM_RAWLINS_ADDRESS
    - HEATHER_LO_ADDRESS
ARCHIBUS

    @js           = Rhubarb::Email.parse_config(js_archibus)
    @js_from_file = Rhubarb::Email.parse_config_file(File.join(File.dirname(__FILE__), 'archibus_email.yaml'))

    js_archibus_w_attachments = <<ARCHIBUS
---
name: ARCHIBUS
outputs:
  foo:
    subject: "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
    message: >
      Attached are the reports that show the results and provide information on
      building/room records successfully updated and any error conditions found,
      if any, as a result of any Archibus files that were processed for the day.
    to:
    - KATT_AUTOMATION_ADDRESS
    - KFS_BSA_ADDRESS
    attachments_dir: 
    - "#{File.join(File.expand_path(File.dirname(__FILE__)), 'attachments')}"
    attachments_globs:
    - buildingImportErrorReport_*.txt
    - buildingImportSuccessReport_*.txt
    - roomImportErrorReport_*.txt
    - roomImportSuccessReport_*.txt  
  bar:
    subject: "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
    message: >
      Attached are the reports that show the results and provide information on
      building/room records successfully updated and any error conditions found,
      if any, as a result of any Archibus files that were processed for the day.
    to:
    - KATT_AUTOMATION_ADDRESS
    - KFS_BSA_ADDRESS
    attachments_dir: 
    - "#{File.join(File.expand_path(File.dirname(__FILE__)), 'attachments')}"
    attachments_globs:
    - buildingImportErrorReport_*.txt
    - buildingImportSuccessReport_*.txt
    - roomImportErrorReport_*.txt
    - roomImportSuccessReport_*.txt
ARCHIBUS
    @js_w_attachments = Rhubarb::Email.parse_config(js_archibus_w_attachments)
  end

  after(:each) do
    @js.outputs['report'].delivery_method :smtp
    @js_from_file.outputs['report'].delivery_method :smtp
    @js_w_attachments.outputs['report'].delivery_method :smtp
    Mail::TestMailer.deliveries.clear
  end

  it "should deliver a basic report for realsies", :email_for_real => true do
    @js.deliver 'foo'
  end

  it "should deliver a basic report for realsies from a config file", :email_for_real => true do
    @js_from_file.deliver 'foo'
  end

  it "should deliver a report w/ attachments for realsies", :email_for_real => true do
    @js_w_attachments.deliver 'foo'
  end

  context "not really delivering" do
    before(:each) do
      cleanse_live
      Rhubarb.stub(:batch_home).and_return(@stg_batch_home)

      @js.outputs['report'].delivery_method :test
      @js_from_file.outputs['report'].delivery_method :test
    end

    it "should deliver a basic report" do
      @js.deliver 'foo'
      should have_sent_email.to("srawlins@email.arizona.edu")
    end

    it "should deliver a basic report from a config file" do
      @js_from_file.deliver 'foo'
      should have_sent_email.to("katt-automation@list.arizona.edu")
      should have_sent_email.to("kfsbsa@list.arizona.edu")
    end
  end
end
