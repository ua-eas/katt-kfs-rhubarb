# Internal: The main class which manages emailing reports for Rhubarb.

require 'mail'

class Rhubarb::Email
  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger

  # Public: Initialize an Email object
  def initialize()
    Rhubarb.validate_batch_home

    @logger = Rhubarb::Logger.new('email')
    debug "Rhubarb::Email initialized."
  end

  # Public: Gets batch home value from the Rhubarb object.
  #
  # Returns a string representing the batch home directory
  def batch_home
    @batch_home ||= Rhubarb.batch_home
  end

  # Public: Parses the email yaml config based on a string passed in
  #           and instantiates a job stream object
  #
  # Returns a job stream object
  def self.parse_config(text)
    config_as_hash = YAML.load text
    Rhubarb::Email::JobStream.new(config_as_hash)
  end

  # Public: Parses the email yaml config from a file and instantiates
  # a job stream object
  #
  # Returns a job stream object
  def self.parse_config_file(file_name)
    # TODO raise if this file doesn't exist
    config_as_hash = YAML.load File.read(file_name.downcase)
    Rhubarb::Email::JobStream.new(config_as_hash)
  end

  # Public: Parses addresses.yaml into a hash
  #
  # hash of addresses
  def self.parse_addresses(file)
    # TODO raise if this file doesn't exist
    @@addresses = YAML.load(File.read file)
  end

  # Public: Get the addresses hash
  #
  # hash of addresses
  def self.addresses
    # TODO raise if @@addresses doesn't exist
    @@addresses
  end
end

require_relative 'email/job_stream'
require_relative 'email/output'
