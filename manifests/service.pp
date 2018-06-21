# Handles the service.
class veeamagent::service inherits veeamagent {
  if $veeamagent::service_manage {
    service { $veeamagent::service_name:
      ensure => $veeamagent::service_ensure,
      enable => $veeamagent::service_enable,
    }

    # Make sure that any new or changed veeam_agent_config's refres the service
    Veeam_agent_config <| |> ~> Service[$veeamagent::service_name]
  }
}
