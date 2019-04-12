# Handles backup repos.
#
# lint:ignore:80chars
# lint:ignore:140chars
# @param ensure Enum['absent', 'present'] Ensure value for a backup repository. Default value: `present`.
# @param location String Location to create a Veeam repository (local path). Default value: ''.
# @param veeamcmd_path Array[String] Path to the `veeam` commands. Shared between Define: `backup_repo` and Define: `backup_job`. Default value: varies by operating system.
# lint:endignore
# lint:endignore
define veeamagent::backup_repo(
  Enum['absent', 'present'] $ensure = lookup('veeamagent::backup_repo::ensure'),
  String $location                  = lookup('veeamagent::backup_repo::location'),
  Array[String] $veeamcmd_path      = lookup('veeamagent::veeamcmd_path'),
) {

  require veeamagent

  $find_repo = $facts['kernel'] ? {
    'Linux' => "veeamconfig repository list | grep -E \'^${title}.*${location}\' || exit 1",
  }

  if ($ensure == present) {
    exec { "Create Repository - ${title}":
      command => "veeamconfig repository create --name \"${title}\" --location \"${location}\"",
      path    => $veeamcmd_path,
      unless  => $find_repo,
    }
  } else {
    exec { "Delete Repository - ${title}":
      command => "veeamconfig repository delete --name \"${title}\"",
      path    => $veeamcmd_path,
      onlyif  => $find_repo,
    }
  }
}
