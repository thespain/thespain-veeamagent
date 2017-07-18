# Handles the main configuration file.
class veeamagent::config inherits veeamagent {
  file { $veeamagent::config_path:
    ensure  => $veeamagent::config_ensure,
    content => epp('veeamagent/veeam.ini.epp'),
    notify  => Class['::veeamagent::service'],
  }
}
