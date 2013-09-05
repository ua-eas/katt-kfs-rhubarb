# Internal: The main class which manages emailing reports for Rhubarb.

require 'mail'

class Rhubarb::Email
  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger



  # Public: Initialize an Email object
  def initialize()
    Rhubarb.validate_batch_home
    @logger = Rhubarb::Logger.new('email')

    parse_addresses

    debug "Rhubarb::Email initialized."
  end

  # Public: Get the addresses hash. Note this is a class method for now
  #         because the output object requires this to do the address
  #         replacements in to and from.
  #
  # hash of addresses
  def self.addresses
    # TODO raise if @@addresses doesn't exist
    @@addresses
  end  

  # Public: This method will instantiate a new jobstream object based on 
  #         the jobstream name that is passed in. For now, this just calls
  #         the private method to acomplish this.
  #
  # job_stream - a string with the name of the jobstream we are attempting
  #              to intialize.
  #
  # Returns a Rhubarb::Email::JobStream object
  def get_jobstream_by_name(job_stream)
    parse_config_file(job_stream)
  end

  # Public: This method will instantiate a new jobstream object based on 
  #         the a text string you pass in. This assumes that you pass in 
  #         yaml text representing the jobstream email config file.
  #
  # config_text - The yaml text representing the jobstream email config 
  #               file. For example:
  # ---
  # name: FOO
  # outputs:
  #   job_start:
  #     subject: "DEV - UAF-FOO-DLV-EMAIL - FOO Started"
  #     message: >
  #       Starting job FOO,
  #       there should be 
  #       a follow-up email after this one.
  #     to:
  #     - SCOTT_SKINNER_ADDRESS
  #     - JOSH_SHALOO_ADDRESS
  #   job_ok:
  #     subject: "DEV - UAF-FOO-DLV-EMAIL - FOO Complete"
  #     message: >
  #       A success email most likely will contain an
  #       attached report for review by end users,
  #       which is the 'preferred' outcome.
  #     to:
  #     - SCOTT_SKINNER_ADDRESS
  #     - JOSH_SHALOO_ADDRESS
  #     attachments_dir:
  #     - /home/u00/env/kfs/opt/work/dev/kfs/reports/foo
  #     attachments_globs:
  #     - foo_report*.txt
  #               
  #
  # Returns a Rhubarb::Email::JobStream object
  def get_jobstream_from_text(config_text)
    parse_config(config_text)
  end
  
  private

  # Internal: Parses the email yaml config based on a string passed in
  #           and instantiates a job stream object
  #
  # Returns a job stream object
  def parse_config(text)
    config_as_hash = YAML.load text
    Rhubarb::Email::JobStream.new(config_as_hash)
  end

  # Interanl: Parses the email yaml config from a file and instantiates
  #           a job stream object
  #
  # Returns a job stream object
  def parse_config_file(job_stream_name)
    # TODO raise if this file doesn't exist
    config_file = get_jobstream_config_file(job_stream_name)
    config_text = File.read(config_file)
    parse_config(config_text)
  end

  # Interanl: Parses addresses.yaml file into a hash and stores it as
  #           a class variable.
  #
  # Returns a hash of addresses
  def parse_addresses

    # TODO raise if this file doesn't exist
    file_name = get_addresses_config_file
    @@addresses = YAML.load(File.read file_name)
  end

  def get_email_config_dir
    email_config_dir = ENV['RHUBARB_CONFIG'] ||= "./spec/test_config"
    email_config_dir += '/current/email/'
  end

  # Internal: Finds the config file for addresses
  #
  # Returns a string representing the full path to the addresses.yaml file.
  def get_addresses_config_file

    addresses_file = get_email_config_dir + '/addresses/'
    if ENV['RHUBARB_ENV']
      addresses_file = ENV['RHUBARB_ENV'] + '_'
    end
    addresses_file += 'addresses.yaml'
  end

  # Internal: Find the config file for a jobstream
  # 
  # job_stream_name - a string containing the name of the jobstream you
  #                   would like to locate the config file for.
  #
  #
  # Returns a string representing the full path to the <jobstream>_email.yaml file.
  def get_jobstream_config_file(job_stream_name)

    config_file_name = get_email_config_dir + job_stream_name + '_email.yaml'
    config_file_name.downcase
  end

end

require_relative 'email/job_stream'
require_relative 'email/output'
require_relative 'email/attachments/file_filter_base'
require_relative 'email/attachments/glob_file_filter'
require_relative 'email/attachments/glob_file_filter_tracker'
