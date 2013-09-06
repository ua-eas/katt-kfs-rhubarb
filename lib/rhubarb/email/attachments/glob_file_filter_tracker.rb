
class Rhubarb::Email::GlobFileFilterTracker < Rhubarb::Email::GlobFileFilter

  def post_initialize( args = {} )
    
    @tracking_directory =  Rhubarb.batch_home
    @tracking_directory += '/reports/emailed/'

    FileUtils.mkdir_p @tracking_directory

  end

  def post_get_attachments(raw_attachments_array=[])

    debug "Begin Rhubarb::Email::GlobFileFilterTracker:post_get_attachments"

    final_attachments_array = []

    raw_attachments_array.each do | file_name |
      
      if should_send_file file_name 

        tracking_file_name = get_tracking_file file_name

        debug 'Adding tracking file: ' + tracking_file_name
        FileUtils.touch tracking_file_name

        debug 'Adding ' + file_name + ' to final list of attachments to send'
        final_attachments_array.push(file_name)

      else
        debug 'Removing ' + file_name + ' from final list of attachments to send'
      end
    
    end

    return final_attachments_array

  end

  def get_tracking_file(file_full_path)
    file_name = File.basename(file_full_path)
    tracking_file_name = @tracking_directory + file_name + '.emailed'
    return tracking_file_name
  end

  def should_send_file(file_name)
    tracking_file = get_tracking_file file_name

    if File.exist?(tracking_file)
      return false
    else
      return true
    end
  end

end