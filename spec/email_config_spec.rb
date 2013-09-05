require_relative 'spec_helper'


describe Rhubarb::Email, "#parse_config" do
  include Helpers



  before(:each) do
    cleanse_live
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)

  end

  before(:all) do

    debugger

    add_test_reports

    email_deliverer = Rhubarb::Email.new

    js_archibus = <<ARCHIBUS
---
name: ARCHIBUS
outputs:
  job_not_ok:
    subject: "DEV - UAF-FOO-DLV-EMAIL - Job Failed"
    message: |
      The job FOO has failed, 
      attached is a log of events,
      please see KFS logs for further detail.
    to: 
    - KATT_AUTOMATION_ADDRESS
    - JOSH_SHALOO_ADDRESS
    attachment_dirs:
    - BATCH_HOME/reports/fooeinvoice
    attachments_globs:
    - GlobFileFilter: [foo_*.log, bar_*.log]
  job_ok:
    subject: "DEV - UAF-FOO-DLV-EMAIL - Job Success"
    message: |
      The job FOO has finished successfully.
    to: 
    - KATT_AUTOMATION_ADDRESS
    - JOSH_SHALOO_ADDRESS
    attachment_dirs:
    - BATCH_HOME/reports/fooeinvoice
    attachments_globs:
    - GlobFileFilter: [foo_*.log, bar_*.log]
    - GlobFileFilterTracker: [baz_*.log]
ARCHIBUS
    @js = email_deliverer.get_jobstream_from_text(js_archibus)
  end

  after(:all) do
    cleanup_email_tracking_files
  end


  it "should generate JobStream representing the whole job_stream, with a correct name" do
    @js.name.should == "ARCHIBUS"
  end

  it "should generate JobStream representing the whole job_stream, with a correct Output" do
    @js.outputs['job_not_ok'].should_not be nil
    @js.outputs['job_ok'].should_not be nil
  end

  it "should generate Output with a correct name" do
    @js.outputs['job_ok'].name.should == "job_ok"
    @js.outputs['job_not_ok'].name.should == "job_not_ok"
  end

  it "should generate Output with a correct subject" do
    @js.outputs['job_ok'].subject.should == "DEV - UAF-FOO-DLV-EMAIL - Job Success"
    @js.outputs['job_not_ok'].subject.should == "DEV - UAF-FOO-DLV-EMAIL - Job Failed"
  end

  it "should generate Output with a correct message" do

    expected =  "The job FOO has finished successfully.\n"
    @js.outputs['job_ok'].text_part.body.to_s.should == "The job FOO has finished successfully.\n"

    expected =  "The job FOO has failed, \nattached is a log of events,\n"
    expected += "please see KFS logs for further detail.\n"
    @js.outputs['job_not_ok'].text_part.body.to_s.should == expected
  end

  it "should generate Output with correct to entries" do
    @js.outputs['job_ok']['to'].to_s.should include("katt-automation@list.arizona.edu")
    @js.outputs['job_ok']['to'].to_s.should include("shaloo@email.arizona.edu")
    @js.outputs['job_not_ok']['to'].to_s.should include("katt-automation@list.arizona.edu")
    @js.outputs['job_not_ok']['to'].to_s.should include("shaloo@email.arizona.edu")
  end

  it "should generate an Output with correct attachments globs" do
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("foo_1.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("foo_2.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("foo_3.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("foo_4.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("bar_1.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("bar_2.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("bar_3.log")
    @js.outputs['job_not_ok'].attachments.map(&:filename).should include("bar_4.log")

    @js.outputs['job_ok'].attachments.map(&:filename).should include("foo_1.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("foo_2.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("foo_3.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("foo_4.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("bar_1.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("bar_2.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("bar_3.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("bar_4.log")
    # the helper creates a tracking file for baz_1.log so this should not be included!
    @js.outputs['job_ok'].attachments.map(&:filename).should_not include("baz_1.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("baz_2.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("baz_3.log")
    @js.outputs['job_ok'].attachments.map(&:filename).should include("baz_4.log")
  end

  it "should generate multiple Outputs" do
    @js.outputs.count.should == 2
  end
end
