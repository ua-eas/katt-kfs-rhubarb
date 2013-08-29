require_relative 'spec_helper'

describe Rhubarb::Email, "#deliver" do
  include Helpers
  include Mail::Matchers

  before(:each) do
    cleanse_live
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
  end

  before(:all) do
    email_deliverer = Rhubarb::Email.new

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
    - JOSH_SHALOO_ADDRESS
  bar:
    subject: "DEV - UAF-ARCHB-DLV-LOADRPT - Archibus Processing Information - Capital Assets Team Review"
    message: >
      Attached are the reports that show the results and provide information on
      building/room records successfully updated and any error conditions found,
      if any, as a result of any Archibus files that were processed for the day.
    to:
    - HEATHER_LO_ADDRESS
ARCHIBUS

    @js           = email_deliverer.get_jobstream_from_text(js_archibus)
    @js_from_file = email_deliverer.get_jobstream_by_name('archibus')

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
    - JOSH_SHALOO_ADDRESS
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
    - HEATHER_LO_ADDRESS
    attachments_dir: 
    - "#{File.join(File.expand_path(File.dirname(__FILE__)), 'attachments')}"
    attachments_globs:
    - buildingImportErrorReport_*.txt
    - buildingImportSuccessReport_*.txt
    - roomImportErrorReport_*.txt
    - roomImportSuccessReport_*.txt
ARCHIBUS
    @js_w_attachments = email_deliverer.get_jobstream_from_text(js_archibus_w_attachments)
  end

  after(:each) do
    @js.set_delivery_method :smtp
    
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

      @js.set_delivery_method :test
      @js_from_file.set_delivery_method :test
      
    end

    it "should deliver a basic report for a single output" do
      @js.deliver 'foo'
      should have_sent_email.to("shaloo@email.arizona.edu")
    end

    it "should deliver a report for all outputs" do
      @js.deliver 'all'
      should have_sent_email.to("shaloo@email.arizona.edu")
      should have_sent_email.to("hlo@email.arizona.edu")
    end

    it "should deliver a basic report from a config file" do
      @js_from_file.deliver 'foo'
      should have_sent_email.to("katt-automation@list.arizona.edu")
      should have_sent_email.to("kfsbsa@list.arizona.edu")
    end
  end
end
