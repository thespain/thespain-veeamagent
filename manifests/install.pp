# Handles the packages.
class veeamagent::install inherits veeamagent {
  if $veeamagent::package_manage {
    package { $veeamagent::package_name:
      ensure => $veeamagent::package_ensure
    }
  }
}
