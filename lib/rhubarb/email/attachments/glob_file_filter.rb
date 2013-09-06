
class Rhubarb::Email::GlobFileFilter < Rhubarb::Email::FileFilterBase

  include Rhubarb::TokenParser

  def get_attachments

  	debug "Begin Rhubarb::Email::GlobFileFilter::get_attachments"
    
    attachments_array = []

    @attachment_dirs.each do |dir_string|

      parsed_dir_string = replace_tokens dir_string

      debug "checking directory " + parsed_dir_string

      @parameters.each do |glob|
        
        debug "checking for files matching " + glob

        Dir.glob(File.join(parsed_dir_string, glob)).each do |file|

          debug "found attachment: " + file

          attachments_array.push(file)

        end

      end

    end

    # Hook to allow subclass objects to implement additional 
    # functionality...
    post_get_attachments(attachments_array)

  end

  def post_get_attachments(attachments_array)
  	debug "no post_get_attachments defined for #{self.class}"
  	return attachments_array
  end

end