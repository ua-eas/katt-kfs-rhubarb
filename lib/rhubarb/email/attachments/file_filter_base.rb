class Rhubarb::Email::FileFilterBase

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger
  def initialize( args = {} )

    @jobstream        = args[:jobstream]
    @output           = args[:output]
    @attachment_dirs  = args[:attachment_dirs]
    @parameters       = args[:parameters]

    @logger = Rhubarb::Logger.new(@jobstream.name)

  	# Hook to allow subclass objects to implement additional 
    # functionality...
  	post_initialize(args)

    debug "#{self.class} initialized."
  end

  def post_initialize(args)
  	debug "no post_initialize defined for #{self.class}"
  	nil
  end

end