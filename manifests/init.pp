# Main class, includes all other classes.
#
# lint:ignore:80chars
# lint:ignore:140chars
# @param config_entries Hash Defines a set of entries for the veeam.ini file. Default value: {}
# @param gpgkey_ca_ensure String Path to the remote Veeam CA GPG Key. Default value: varies by operating system.
# @param gpgkey_ca_local String Path to the local Veeam CA GPG Key. Default value: varies by operating system.
# @param gpgkey_ca_source String Path to the remote Veeam CA GPG Key. Default value: varies by operating system.
# @param gpgkey_ensure String Ensure value for the local Veeam GPG keys. Default value: varies by operating system.
# @param gpgkey_local String Path to the local Veeam GPG Key. Default value: varies by operating system.
# @param gpgkey_source String Path to the remote Veeam GPG Key. Default value: varies by operating system.
# @param package_ensure String Ensure value for the Veeam package. Default value: `present`.
# @param package_manage Boolean Whether to manage the Veeam package. Default value: `true`.
# @param package_name [Array[String]] Name for the Veeam package. Default value: varies by operating system.
# @param repo_manage Boolean Whether to manage the Veeam package repository. Default value: varies by operating system.
# @param repo_path String Path to where package repositoy files are located. Default value: varies by operating system.
# @param repo_template String Path to a template for the Veeeam package repository. Default value: `'veeamagent/veeam-repo.epp'`.
# @param service_enable Boolean Whether to enable the Veeam service. Default value: `true`.
# @param service_ensure String Ensure value for the Veeam service. Default value: `running`.
# @param service_manage Boolean Manage the service of the Veeam agent. Default value: true
# @param service_name String Name of the Veeam service. Default value: varies by operating system.
# lint:endignore
# lint:endignore
class veeamagent(
  Boolean $package_manage,
  Boolean $repo_manage,
  Boolean $service_enable,
  Boolean $service_manage,
  Hash $config_entries,
  String[1] $gpgkey_ca_ensure,
  String[1] $gpgkey_ca_local,
  String[1] $gpgkey_ca_source,
  String[1] $gpgkey_ensure,
  String[1] $gpgkey_local,
  String[1] $gpgkey_source,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $repo_path,
  String[1] $repo_template,
  String[1] $service_ensure,
  String[1] $service_name,
) {

  contain veeamagent::preinstall
  contain veeamagent::install
  contain veeamagent::config
  contain veeamagent::service

  Class['veeamagent::preinstall']
  -> Class['veeamagent::install']
  -> Class['veeamagent::config']
  -> Class['veeamagent::service']
}
