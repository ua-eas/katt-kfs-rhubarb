require 'redcarpet'

class Rhubarb::Email::Output < Mail::Message
  attr_reader :name, :attachments_dir, :attachments_globs

  def initialize(config={})
    super()

    @name              = config['name']

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
