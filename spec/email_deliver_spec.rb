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

    @js_from_file = email_deliverer.get_jobstream_by_name('archibus')
    @js_w_attachments = email_deliverer.get_jobstream_by_name('einvoice')
  end

  after(:each) do
    @js_from_file.set_delivery_method :smtp
    
    Mail::TestMailer.deliveries.clear
  end

  it "should deliver a basic report for realsies", :email_for_real => true do
    @js_from_file.deliver 'foo'
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

      @js_from_file.set_delivery_method :test
      @js_w_attachments.set_delivery_method :test
      
    end

    it "should deliver a basic report for a single output" do
      @js_from_file.deliver 'foo'
      should have_sent_email.to("kfsbsa@list.arizona.edu")
    end

    it "should deliver a report for all outputs" do
      @js_w_attachments.deliver 'all'
      should have_sent_email.to("shaloo@email.arizona.edu")
      should have_sent_email.to("katt-automation@list.arizona.edu")
    end

    it "should deliver a basic report from a config file" do
      @js_from_file.deliver 'foo'
      should have_sent_email.to("katt-automation@list.arizona.edu")
      should have_sent_email.to("kfsbsa@list.arizona.edu")
    end
  end
end
