# Handles backup jobs.
#
# Note about the Execs:
# When parameters of the job change, then delete the backup job and reimport it.
# An extra level of complication is added when using Veeam B&R repositories.
# In order to successfully re-import a job the VBR server must be deleted
# before re-importing, as well as resyncing the VBR server for repositories.
#
# lint:ignore:80chars
# lint:ignore:140chars
# @param block_size String Data block size (in kilobytes). Default value: `KbBlockSize1024`.
# @param compression_type String Data compression level. Default value:  `Lz4`.
# @param config_dir String Location of Veeam configuration files. Default value: varies by operating system.
# @param enable_dedup Boolean Whether to eneble deduplication. Default value: `true`.
# @param enabled Boolean Whether the job is enebled to run. Default value: `true`.
# @param ensure [Enum['absent', 'present']] Whether the job should exist. Default value: `present`.
# @param index_all Boolean Defines that Veeam Agent for Linux must index all files on the volumes included in backup. Default value: `false`.
# @param max_points Integer The number of restore points that you want to store in the backup location. Default value: `14`.
# @param object_type String The type of backup job to create. Default value: `AllSystem`.
# @param object_value [Optional[String]] Files or directories that apply to the `record_type`. Default value: ''.
# @param post_jobcommand [Optional[String]] Path to the script that should be executed after the backup job completes. Default value: ''.
# @param post_thawcommand [Optional[String]] Path to the script that should be executed after the snapshot creation. This option is available only if Veeam Agent for Linux operates in the server mode. Default value: ''.
# @param pre_freezecommand [Optional[String]] Path to the script that should be executed before the snapshot creation. This option is available only if Veeam Agent for Linux operates in the server mode. Default value: ''.
# @param pre_jobcommand [Optional[String]] Path to the script that should be executed at the start of the backup job. Default value: ''.
# @param record_type String Whether to include or exclude `object_value` for the backup jobs. Default value: `Include`.
# @param repo_name String Name of the repository to where the backups will be saved. Default value: `undef`.
# @param retry_count Integer Number of times to retry the backup job. Default value: `3`.
# @param run_friday [Optional[Boolean]] Whether to schedule the backup job to run on Fridays. Default value: `false`.
# @param run_hour [Optional[Integer]] What hour, in 24 hour time, to schedule the backup job to run. Default value: ''.
# @param run_minute [Optional[Integer]] What minute to schedule the backup job to run. Default value: ''.
# @param run_monday [Optional[Boolean]] Whether to schedule the backup job to run on Mondays. Default value: `false`.
# @param run_saturday [Optional[Boolean]] Whether to schedule the backup job to run on Saturdays. Default value: `false`.
# @param run_sunday [Optional[Boolean]] Whether to schedule the backup job to run on Sundays. Default value: `false`.
# @param run_thursday [Optional[Boolean]] Whether to schedule the backup job to run on Thursdays. Default value: `false`.
# @param run_tuesday [Optional[Boolean]] Whether to schedule the backup job to run on Tuesdays. Default value: `false`.
# @param run_wednesday [Optional[Boolean]] Whether to schedule the backup job to run on Wednesdays. Default value: `false`.
# @param vbrserver_domain [Optional[String]] The domain of the user account used to connect to the Veeam Backup & Replication server. Default value: ''.
# @param vbrserver_fqdn [Optional[String]] The fully qualified domain name of the Veeam Backup & Replication server. Default value: ''.
# @param vbrserver_login [Optional[String]] The name of the user account used to connect to the Veeam Backup & Replication server. Default value: ''.
# @param vbrserver_password [Optional[String]] The password of the user account used to connect to the Veeam Backup & Replication server. Default value: ''.
# @param vbrserver_port [Optional[String]] The port used to connect to the Veeam Backup & Replication server. Default value: `10002`.
# @param veeamcmd_path [Array[String]] Path to the `veeam` commands. Shared between Define: `backup_repo` and Define: `backup_job`. Default value: varies by operating system.
# lint:endignore
# lint:endignore
define veeamagent::backup_job(
  String $block_size                   = lookup('veeamagent::backup_job::block_size'),
  String $compression_type             = lookup('veeamagent::backup_job::compression_type'),
  String $config_dir                   = lookup('veeamagent::backup_job::config_dir'),
  Boolean $enable_dedup                = lookup('veeamagent::backup_job::enable_dedup'),
  Boolean $enabled                     = lookup('veeamagent::backup_job::enabled'),
  Enum['absent', 'present'] $ensure    = lookup('veeamagent::backup_job::ensure'),
  Boolean $index_all                   = lookup('veeamagent::backup_job::index_all'),
  Integer $max_points                  = lookup('veeamagent::backup_job::max_points'),
  String $object_type                  = lookup('veeamagent::backup_job::object_type'),
  Optional[String] $object_value       = lookup('veeamagent::backup_job::object_value'),
  Optional[String] $post_jobcommand    = lookup('veeamagent::backup_job::post_jobcommand'),
  Optional[String] $post_thawcommand   = lookup('veeamagent::backup_job::post_thawcommand'),
  Optional[String] $pre_freezecommand  = lookup('veeamagent::backup_job::pre_freezecommand'),
  Optional[String] $pre_jobcommand     = lookup('veeamagent::backup_job::pre_jobcommand'),
  String $record_type                  = lookup('veeamagent::backup_job::record_type'),
  String $repo_name                    = lookup('veeamagent::backup_job::repo_name'),
  Integer $retry_count                 = lookup('veeamagent::backup_job::retry_count'),
  Optional[Boolean] $run_friday        = lookup('veeamagent::backup_job::run_friday'),
  Optional[Integer] $run_hour          = lookup('veeamagent::backup_job::run_hour'),
  Optional[Integer] $run_minute        = lookup('veeamagent::backup_job::run_minute'),
  Optional[Boolean] $run_monday        = lookup('veeamagent::backup_job::run_monday'),
  Optional[Boolean] $run_saturday      = lookup('veeamagent::backup_job::run_saturday'),
  Optional[Boolean] $run_sunday        = lookup('veeamagent::backup_job::run_sunday'),
  Optional[Boolean] $run_thursday      = lookup('veeamagent::backup_job::run_thursday'),
  Optional[Boolean] $run_tuesday       = lookup('veeamagent::backup_job::run_tuesday'),
  Optional[Boolean] $run_wednesday     = lookup('veeamagent::backup_job::run_wednesday'),
  Optional[String] $vbrserver_domain   = lookup('veeamagent::backup_job::vbrserver_domain'),
  Optional[String] $vbrserver_fqdn     = lookup('veeamagent::backup_job::vbrserver_fqdn'),
  Optional[String] $vbrserver_login    = lookup('veeamagent::backup_job::vbrserver_login'),
  Optional[String] $vbrserver_password = lookup('veeamagent::backup_job::vbrserver_password'),
  Integer $vbrserver_port              = lookup('veeamagent::backup_job::vbrserver_port'),
  Array[String] $veeamcmd_path         = lookup('veeamagent::veeamcmd_path'),
) {
  require veeamagent

  Veeamagent::Backup_repo <| |> -> Veeamagent::Backup_job <| |>

  if ($ensure == present) {
    file { "${config_dir}/${title}.xml":
      ensure  => file,
      content => epp('veeamagent/veeam-config.xml.epp', {
        'block_size'         => $block_size,
        'compression_type'   => $compression_type,
        'enable_dedup'       => $enable_dedup,
        'enabled'            => $enabled,
        'index_all'          => $index_all,
        'max_points'         => $max_points,
        'name'               => $name,
        'object_type'        => $object_type,
        'object_value'       => $object_value,
        'post_jobcommand'    => $post_jobcommand,
        'post_thawcommand'   => $post_thawcommand,
        'pre_freezecommand'  => $pre_freezecommand,
        'pre_jobcommand'     => $pre_jobcommand,
        'record_type'        => $record_type,
        'repo_name'          => $repo_name,
        'retry_count'        => $retry_count,
        'run_friday'         => $run_friday,
        'run_hour'           => $run_hour,
        'run_minute'         => $run_minute,
        'run_monday'         => $run_monday,
        'run_saturday'       => $run_saturday,
        'run_sunday'         => $run_sunday,
        'run_thursday'       => $run_thursday,
        'run_tuesday'        => $run_tuesday,
        'run_wednesday'      => $run_wednesday,
        'vbrserver_domain'   => $vbrserver_domain,
        'vbrserver_fqdn'     => $vbrserver_fqdn,
        'vbrserver_login'    => $vbrserver_login,
        'vbrserver_password' => $vbrserver_password,
        'vbrserver_port'     => $vbrserver_port,
        }),
      require => Class['veeamagent::service'],
      notify  => Exec["Delete Backup Job - ${title}"],
    }

    if ($vbrserver_fqdn) {
      $vbrserver_name = regsubst($vbrserver_fqdn, '^(\S*?)\.(.*?)$', '\1')

      exec { "Resync VBR Repos - ${title}":
        command     => 'veeamconfig vbrserver resync',
        path        => $veeamcmd_path,
        refreshonly => true,
        subscribe   => File["${config_dir}/${title}.xml"],
        require     => Exec["Import Backup Job - ${title}"],
      }

      exec { "Delete vbrserver - ${title}":
        command     => "veeamconfig vbrserver delete --name ${vbrserver_name} | exit 0",
        path        => $veeamcmd_path,
        refreshonly => true,
        subscribe   => File["${config_dir}/${title}.xml"],
        require     => Exec["Delete Backup Job - ${title}"],
        before      => Exec["Import Backup Job - ${title}"],
      }
    }

    exec { "Delete Backup Job - ${title}":
      command     => "veeamconfig job delete --force --name \"${title}\" | exit 0",
      path        => $veeamcmd_path,
      refreshonly => true,
      notify      => Exec["Import Backup Job - ${title}"],
    }

    exec { "Import Backup Job - ${title}":
      command     => "veeamconfig config import --force --file \"${config_dir}/${title}.xml\"",
      path        => $veeamcmd_path,
      refreshonly => true,
    }
  } else {
    file { "${config_dir}/${title}.xml":
      ensure  => absent,
      require => Class['veeamagent::service'],
      notify  => Exec["Delete Backup Job - ${title}"],
    }

    exec { "Delete Backup Job - ${title}":
      command     => "veeamconfig job delete --force --name \"${title}\"",
      path        => $veeamcmd_path,
      refreshonly => true,
    }
  }
}
