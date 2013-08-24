# Internal: A class that represents the email delivery functionality for a job stream.
#           This class is responsible for instanciating an email output and 
#           controls the email delivery flow for one or all output reports.
#
# Instance Variables:
# @name    - String representing the name of the job stream. For example archibus.
# @outputs - A hash with the name of each output report as the key and
#            corresponding output object as the value.
#
class Rhubarb::Email::JobStream
  # Public: read the name and outputs 
  attr_reader :name, :outputs

  # Public: Initializes the JobStream object. It will loop through all outputs in an
  #         email configuration yaml file and instantiate a corresponding email output
  #         message object to build the @outputs hash.
  #
  # config  - A hash with the email configuration.
  #
  def initialize(config={})
    @name = config['name']
    @outputs = {}

    # target_name = key, the target name
    # target_entry = value, a nested hash, specific email info for each target
    config['outputs'].each do |target_name, target_entry|
        @outputs[target_name] = Rhubarb::Email::Output.new(target_entry)
    end

  end

  # Public: Delivers one or more outputs for the target output. Note we are able to deliver
  #         a message for a single output target or we can deliver all messages.
  #
  # target_output_name - The name of the output we would like to deliver. This can either be
  #                      the all keyword or the name of an output defined in the configuration
  #                      yaml.
  #
  def deliver(target_output_name)

    if target_output_name == 'all'
        #send all in an each loop
        @outputs.each_value do |output|
            output.deliver!
        end

    elsif @outputs[target_output_name]
        # send just the output name
        @outputs[target_output_name].deliver!

    else
        #throw some exception because the target is undefined.
        raise "Could not find output with name: " + target_output_name

    end

  end

  # Public: Sets the delivery method for all outputs for the job stream.
  #
  # method - This is the method we would like to set. This is used in test mode
  #          to change the delivery method to :test so it does not actually send
  #          the email.
  #
  def set_delivery_method(method)

    @outputs.each_value do |output|
        output.delivery_method method
    end
    
  end

end
