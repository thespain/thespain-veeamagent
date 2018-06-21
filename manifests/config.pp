# Handles the main configuration file.
class veeamagent::config inherits veeamagent {
  $config_file_version = $veeamagent::agent_version ? {
    1 => 'v1.0.1.364',
    2 => 'v2.0.0.400',
  }

  file { $veeamagent::config_path:
    ensure  => $veeamagent::config_ensure,
    content => epp('veeamagent/veeam.ini.epp', {
      config_file_version => $config_file_version
    }),
    notify  => Class['::veeamagent::service'],
  }
}
