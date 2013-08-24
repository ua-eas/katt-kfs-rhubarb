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

  # Public: Gets the attachments_dir and attachments_globs
  attr_reader :attachments_dir, :attachments_globs

  # Public: Initializes the Output object and actually builds the email message.
  #
  # config  - A hash with the output email configuration from the jobstream's email config
  #           yaml file.
  #
  def initialize(config={})
    super()

    self['subject']    = config['subject']

    self.text_part do
      body config['message']
    end

    self.html_part do
      content_type 'text/html; charset=UTF-8'
      body Redcarpet::Markdown.new(Redcarpet::Render::HTML, :no_intra_emphasis=>true).render(config['message'])
    end

    self['from']       = Rhubarb::Email.addresses['FROM_ADDRESS']

    recipients         = []
    config['to'].each do |key|
      recipients << Rhubarb::Email.addresses[key]
    end
    self['to']         = recipients.join(',')

    @attachments_dir   = config['attachments_dir']
    @attachments_globs = config['attachments_globs']
    if @attachments_dir and @attachments_globs
      @attachments_dir.each do |dir|
        @attachments_globs.each do |glob|
          Dir.glob(File.join(dir, glob)).each do |file|
            self.add_file file
          end
        end
      end
    end
  end
end
