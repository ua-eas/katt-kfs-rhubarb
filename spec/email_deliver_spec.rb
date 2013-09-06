require_relative 'spec_helper'

describe Rhubarb::Email, ".new" do
  include Helpers
  include Mail::Matchers

  before(:each) do
    cleanse_live
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
  end

  before(:all) do

    debugger

    email_deliverer_from_file = Rhubarb::Email.new('archibus')
    email_deliverer_w_attachments = Rhubarb::Email.new('einvoice')

    @js_from_file = email_deliverer_from_file.get_jobstream
    @js_w_attachments = email_deliverer_w_attachments.get_jobstream
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
      @js_from_file.should have_sent_email.to("kfsbsa@list.arizona.edu")
    end

    it "should deliver a report for all outputs" do
      @js_w_attachments.deliver 'all'
      @js_w_attachments.should have_sent_email.to("shaloo@email.arizona.edu")
      @js_w_attachments.should have_sent_email.to("katt-automation@list.arizona.edu")
    end

    it "should deliver a basic report from a config file" do
      @js_from_file.deliver 'foo'
      @js_from_file.should have_sent_email.to("katt-automation@list.arizona.edu")
      @js_from_file.should have_sent_email.to("kfsbsa@list.arizona.edu")
    end
  end
end
