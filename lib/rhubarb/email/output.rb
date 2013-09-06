# Red carpet is used to format the email messages.
require 'redcarpet'

# Internal: Rhubarb::Email::Output extends the Mail::Message class and is responsible
#           for building and delivering an email message
#
# Instance Variables:
# @attachments_dir   - The directory where we look for attachments
# @attachments_globs - The globs representing which files to attach to the report
#
class Rhubarb::Email::Output < Mail::Message

  include Rhubarb::TokenParser

  # Public: Gets the attachments_dir and attachments_globs
  attr_reader :attachment_dirs, :attachments_files, :config, :name, :jobstream

  delegate :debug, :info, :warn, :error, :fatal, :log_to_stdout, to: :@logger


  # Public: Initializes the Output object and actually builds the email message.
  #
  # config  - A hash with the output email configuration from the jobstream's email config
  #           yaml file.
  #
  def initialize( args = {} )
    super()

    Rhubarb.validate_batch_home
    @logger = Rhubarb::Logger.new('email')

    @config    = args[:config]
    @name      = args[:target_name]
    @jobstream = args[:jobstream]

    subject = @config['subject']
    subject = replace_tokens subject
    self['subject'] = subject

    message = @config['message']
    message = replace_tokens message

    self.text_part do
      body message
    end

    self.html_part do
      content_type 'text/html; charset=UTF-8'
      body Redcarpet::Markdown.new( Redcarpet::Render::HTML, :no_intra_emphasis=>true).render(message)
    end

    self['from']       = Rhubarb::Email.addresses['FROM_ADDRESS']

    recipients         = []
    @config['to'].each do |key|
      recipients << Rhubarb::Email.addresses[key]
    end
    self['to']         = recipients.join(',')

    if @config['attachment_dirs'] && @config['attachments']

      @attachment_dirs = @config['attachment_dirs']
      @attachment_files = get_attachment_files
      
      if @attachment_files
        @attachment_files.each do |file|
          self.add_file file
        end
      end
    end
  end

  private

  def get_attachment_files
    attachments = []

    @config['attachments'].each do | attachment_hash |
      attachment_hash.each do | class_name, parameter_array |
        attachment_filter = Object::const_get('Rhubarb::Email::' + class_name).new( 
          :output          => self,
          :parameters      => parameter_array,
          :jobstream       => jobstream,
          :attachment_dirs => @attachment_dirs
        )
        attachments += attachment_filter.get_attachments
      end
    end
    return attachments
  end
end
