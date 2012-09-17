require_relative 'spec_helper'

describe Rhubarb::LogRoller, '.new' do
  include Helpers

  before(:all) do
    cleanse_live
  end

  it 'should abandon ship without $BATCH_HOME' do
    Rhubarb.stub(:batch_home).and_return(nil)
    expect { Rhubarb::LogRoller.new }.to raise_error(Rhubarb::MissingBatchHomeError)
  end

  it 'should abandon ship with an invalid $BATCH_HOME' do
    batch_home = File.join(@live_dir, 'uaf-fake')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::LogRoller.new }.to raise_error(Rhubarb::InvalidBatchHomeError)
  end

  it 'should abandon ship with an empty $BATCH_HOME directory' do
    batch_home = File.join(@live_dir, 'uaf-tst')
    Rhubarb.stub(:batch_home).and_return(batch_home)
    expect { Rhubarb::LogRoller.new }.to raise_error(Rhubarb::EmptyBatchHomeError)
  end

  it 'should initialize successfully' do
    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    expect { Rhubarb::LogRoller.new }.to_not raise_error
  end
end

describe Rhubarb::LogRoller, '#roll' do
  include Helpers

  before(:each) do
    cleanse_live

    Rhubarb.stub(:batch_home).and_return(@stg_batch_home)
    @logger01 = Rhubarb::Logger.new('foo')
    @logger02 = Rhubarb::Logger.new('bar')
    @message01 = 'Ridiculously Interesting Message'

    @roller = Rhubarb::LogRoller.new
  end

  it 'should not blow up if there is nothing to roll' do
    expect { @roller.roll }.to_not raise_error
  end

  context 'after log files has been written to' do
    before(:each) do
      @logger01.info @message01
      @logger02.info @message01

      @roller.roll
    end

    it 'should roll log files out of the way' do
      Dir.glob(File.join(@stg_batch_home, 'logs', '*.log')).should be_empty
    end

    it 'should roll log files into their archive location' do
      File.directory?(File.join(@stg_batch_home, 'logs', 'foo')).should be_true
      File.directory?(File.join(@stg_batch_home, 'logs', 'bar')).should be_true
    end

    it 'should keep log files correct' do
      last_foo_log = Dir.glob(File.join(@stg_batch_home, 'logs', 'foo', '*.log')).last
      lines = File.readlines(last_foo_log)
      lines.last.should match /[0-9:]{8} \(INFO\) #{@message01}/

      last_bar_log = Dir.glob(File.join(@stg_batch_home, 'logs', 'bar', '*.log')).last
      lines = File.readlines(last_bar_log)
      lines.last.should match /[0-9:]{8} \(INFO\) #{@message01}/
    end
  end

  it 'should keep multiple log files, one for each day' do
    day_zero = Time.local(2012, 9, 1, 12, 00, 00)
    day_one = Time.local(2012, 9, 2, 12, 00, 00)
    day_two = Time.local(2012, 9, 3, 12, 00, 00)

    Timecop.travel(day_zero) do
      @logger01.info @message01
      @logger02.info @message01

      @roller.roll
    end

    # We just pulled the rug out from under these kids, so we have to reinitialize
    @logger01 = Rhubarb::Logger.new('foo')
    @logger02 = Rhubarb::Logger.new('bar')

    Timecop.travel(day_one) do
      @logger01.info @message01
      @logger02.info @message01

      @roller.roll
    end

    # We just pulled the rug out from under these kids, so we have to reinitialize
    @logger01 = Rhubarb::Logger.new('foo')
    @logger02 = Rhubarb::Logger.new('bar')

    Timecop.travel(day_two) do
      @logger01.info @message01
      @logger02.info @message01

      @roller.roll
    end

    foo_archives = Dir.glob(File.join(@stg_batch_home, 'logs', 'foo', '*.log'))
    foo_archives.should include_something_like /foo_2012-08-31.log$/
    foo_archives.should include_something_like /foo_2012-09-01.log$/
    foo_archives.should include_something_like /foo_2012-09-02.log$/
    foo_archives.should_not include_something_like /foo_2012-09-03.log$/

    bar_archives = Dir.glob(File.join(@stg_batch_home, 'logs', 'bar', '*.log'))
    bar_archives.should include_something_like /bar_2012-08-31.log$/
    bar_archives.should include_something_like /bar_2012-09-01.log$/
    bar_archives.should include_something_like /bar_2012-09-02.log$/
    bar_archives.should_not include_something_like /bar_2012-09-03.log$/
  end
end
