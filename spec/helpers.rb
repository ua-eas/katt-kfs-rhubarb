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
  def add_test_reports

    report_dir = Rhubarb.batch_home + '/reports/fooeinvoice'
    FileUtils.mkdir_p report_dir

    FileUtils.touch [ 
      report_dir + "/foo_1.log", 
      report_dir + "/foo_2.log", 
      report_dir + "/foo_3.log", 
      report_dir + "/foo_4.log"
    ]
    FileUtils.touch [ 
      report_dir + "/bar_1.log", 
      report_dir + "/bar_2.log", 
      report_dir + "/bar_3.log", 
      report_dir + "/bar_4.log"
    ]
    FileUtils.touch [ 
      report_dir + "/ARCHIBUSFOO_baz_1.log", 
      report_dir + "/ARCHIBUSFOO_baz_2.log", 
      report_dir + "/ARCHIBUSFOO_baz_3.log", 
      report_dir + "/ARCHIBUSFOO_baz_4.log"
    ]

    #add a tracking dir
    report_dir = Rhubarb.batch_home + '/reports/emailed/'
    FileUtils.mkdir_p report_dir

    #add a tracking file for one of the baz reports to simulate tracking
    FileUtils.touch Rhubarb.batch_home + '/reports/emailed/ARCHIBUSFOO_baz_1.log.emailed'

  end
  def cleanup_email_tracking_files
    #clean up the fake reports
    FileUtils.rm_rf Rhubarb.batch_home + '/reports/fooeinvoice'
    #clean up tracking files
    FileUtils.rm Rhubarb.batch_home + '/reports/emailed/ARCHIBUSFOO_baz_1.log.emailed'
    FileUtils.rm Rhubarb.batch_home + '/reports/emailed/ARCHIBUSFOO_baz_2.log.emailed'
    FileUtils.rm Rhubarb.batch_home + '/reports/emailed/ARCHIBUSFOO_baz_3.log.emailed'
    FileUtils.rm Rhubarb.batch_home + '/reports/emailed/ARCHIBUSFOO_baz_4.log.emailed'
  end
end
