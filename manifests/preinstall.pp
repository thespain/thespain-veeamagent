# Handles the package repository, if applicable.
class veeamagent::preinstall inherits veeamagent {
  if $veeamagent::repo_manage {
    case $facts['os']['family'] {
      'RedHat': {
        yum::gpgkey { $veeamagent::gpgkey_ca_local:
          ensure => $veeamagent::gpgkey_ca_ensure,
          source => $veeamagent::gpgkey_ca_source,
        }

        yum::gpgkey { $veeamagent::gpgkey_local:
          ensure => $veeamagent::gpgkey_ensure,
          source => $veeamagent::gpgkey_source,
        }
      }

      default: {
        fail("Repository management is not supported ${facts['os']['family']}")
      }
    }

    file { $veeamagent::repo_path:
      ensure  => file,
      content => epp($veeamagent::repo_template),
    }
  }
}
