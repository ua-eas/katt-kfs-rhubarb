module Helpers
  def cleanse_live
    @live_dir       = File.join(File.dirname(__FILE__), 'live')
    @canon_dir      = File.join(File.dirname(__FILE__), 'canon')
    @live_files     = File.join(@live_dir, '*')
    @canon_files    = File.join(@canon_dir, '*')
    @cfg_batch_home = File.join(@live_dir, 'uaf-cfg')
    @stg_batch_home = File.join(@live_dir, 'uaf-stg')
    @trn_batch_home = File.join(@live_dir, 'uaf-trn')
    @sql_home       = File.join(@live_dir, 'sql')

    # Delete everything in 'live'
    FileUtils.rm_rf Dir.glob(@live_files)

    # Copy from 'canon' to 'live'
    FileUtils.cp_r Dir.glob(@canon_files), @live_dir

    # For writable tests
    FileUtils.chmod 0500, File.join(@live_dir, 'uaf-trn', 'control')
  end
  def create_required_dirs
    FileUtils.mkdir_p Rhubarb.batch_home
  end
end
