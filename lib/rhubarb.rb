require 'active_support/core_ext'
require 'log4r'

# A project that joins Control-M, or any other job scheduling system, to the
# KFS Batch Invoker
#
# Rhubarb's main purpose is to drop a runfile for the Invoker to pick up, wait
# for a corresponding statusfile, and return whether or not the job apparently
# succeeded. These activities are carried out by the {Rhubarb::Driver}.
#
# Secondarily, Rhubarb is capable of logging activities, rolling log files, and
# potentially notifying via email.
#
# Rhubarb is designed to be primarily used as a small set of binaries that can
# be executed by Control-M, or any job scheduling system.
module Rhubarb
  # For now, this is purely `$BATCH_HOME`.
  #
  # This method is purely to allow me to mock the instance method. I don't like
  # this but there it is.
  #
  # @return [String]
  def self.batch_home
    ENV['BATCH_HOME']
  end

  # The "control" directory inside the {Rhubarb.batch\_home} directory. If
  # {Rhubarb.batch\_home} is `"/transaction-kfs"`, then this method will return
  # `"/transaction-kfs/control"`.
  #
  # @return [String]
  def self.control_dir
    File.join(batch_home, 'control')
  end

  # Validates the {Rhubarb.batch\_home} directory structure, raising an exception if
  # it is not valid.
  #
  # @return nil
  #
  # @raise [Rhubarb::MissingBatchHomeError] if {Rhubarb.batch\_home} is `nil`
  #
  # @raise [Rhubarb::InvalidBatchHomeError] if {Rhubarb.batch\_home} does not exist in
  #   the filesystem
  #
  # @raise [Rhubarb::EmptyBatchHomeError] if {Rhubarb.batch\_home} is an empty
  #   directory
  def self.validate_batch_home
    raise Rhubarb::MissingBatchHomeError if batch_home.nil?
    raise Rhubarb::InvalidBatchHomeError if not File.exist? batch_home
    batch_home_entries = Dir.new(batch_home).entries.reject {|e| e =~ /\.+|placeholder.txt/}
    raise Rhubarb::EmptyBatchHomeError if batch_home_entries.empty?
  end

  # EmptyBatchHomeError is raised when the Batch Home directory exists, but is empty.
  class EmptyBatchHomeError < StandardError
  end

  # InvalidBatchHomeError is raised when the Batch Home directory does not
  # exist in the filesystem.
  class InvalidBatchHomeError < StandardError
  end

  # MissingBatchHomeError is raised when {Rhubarb.batch\_home} (likely just
  # `$BATCH_HOME`) is not set.
  class MissingBatchHomeError < StandardError
  end

  # MissingControlDirectoryError is raised when the control directory does not
  # exist in the filesystem.
  class MissingControlDirectoryError < StandardError
  end

  # StatusFileTimeoutError is raised when either the runfile did not disappear,
  # or the statusfile did not appear, before the timeout.
  class StatusFileTimeoutError < StandardError
  end

  # UnwritableControlDirectoryError is raised when the control directory
  # exists, but is not writable by the current user.
  class UnwritableControlDirectoryError < StandardError
  end

  module TokenParser

    def get_token_map 
      @token_map ||= build_token_map
    end

    def build_token_map
      @token_map = {
        'ENV'        => get_env_value,
        'DATE'       => get_date_value,
        'TIME'       => get_time_value,
        'BATCH_HOME' => Rhubarb.batch_home
      }
    end

    def get_env_value 
      @@rhubarb_env ||= ENV['RHUBARB_ENV']
    end

    def get_date_value 
      time = Time.new
      time.strftime("%m/%d/%Y")
    end

    def get_time_value
      time = Time.new
      time.strftime("%H:%M:%S")
    end

    def replace_tokens( target_string = '' )
      tokens = get_token_map

      tokens.each { | token, value |
        target_string = target_string.gsub( %r{#{token}}, "#{value}" )
      }
      return target_string
    end
  end

end

require_relative 'rhubarb/logger'
require_relative 'rhubarb/log_roller'
require_relative 'rhubarb/archivist'
require_relative 'rhubarb/driver'
require_relative 'rhubarb/sql'
require_relative 'rhubarb/calendar'
require_relative 'rhubarb/email'
