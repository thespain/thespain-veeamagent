# Handles the main configuration file.
class veeamagent::config inherits veeamagent {
  create_resources(veeam_agent_config, $veeamagent::config_entries)
}
