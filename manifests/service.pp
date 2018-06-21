# Handles the service.
class veeamagent::service inherits veeamagent {
  if $veeamagent::service_manage {
    service { $veeamagent::service_name:
      ensure    => $veeamagent::service_ensure,
      enable    => $veeamagent::service_enable,
      subscribe => File[$veeamagent::config_path]
    }
  }
}
