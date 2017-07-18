# Handles the service.
class veeamagent::service inherits veeamagent {
  service { $veeamagent::service_name:
    ensure => $veeamagent::service_ensure,
    enable => $veeamagent::service_enable,
  }
}
