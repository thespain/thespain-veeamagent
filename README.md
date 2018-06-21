[![Build Status](https://img.shields.io/travis/thespain/thespain-veeamagent/master.svg)](https://travis-ci.org/thespain/thespain-veeamagent/branches)
[![Coverage Status](https://coveralls.io/repos/github/thespain/thespain-veeamagent/badge.svg?branch=master)](https://coveralls.io/github/thespain/thespain-veeamagent?branch=master)
[![Puppet Forge](https://img.shields.io/puppetforge/v/thespain/veeamagent.svg)](https://forge.puppet.com/thespain/veeamagent)
[![GitHub tag](https://img.shields.io/github/tag/thespain/thespain-veeamagent.svg)](https://github.com/thespain/thespain-veeamagent)

# veeamagent

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with veeamagent](#setup)
    * [What veeamagent affects](#what-veeamagent-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with veeamagent](#beginning-with-veeamagent)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The veeamagent module installs, configures, and manages the Veeam Agent,
Veeam backup jobs, and local repositories.

This module is compatible with all Veeam Agent Editions
(Free, Workstation, & Server), including leveraging
Veeam Backup & Replication backup repositories.

## Setup

### What veeamagent affects

**Linux Users Only:** A kernel module called
[veeamsnap](https://github.com/veeam/veeamsnap) will be installed as
required by the Veeam Agent for Linux to implement volume snapshots
and change block tracking.

### Setup Requirements

For use with Veeam Backup & Replication you must have a Workstation or Server
Edition License imported in the console and you must edit the backup
repository "Agent Permissions" to allow agents to connect.

**Linux Users Only:** As a result of installing and compiling the `veeamsnap` kernel
module the agented machine may require a manual reboot after installation in
order for a backup job to successfully complete.

### Beginning with veeamagent

To install the agent without any backup jobs or repos simply `include veeamagent`.
If you wish to use this module solely for managing settings in `veeam.ini` then
instead use

```pupppet
class { 'veeamagent':
  package_manage => false,
  service_manage => false,
}
```

## Usage

### Manage veeam.ini and the agent's service only

When agents are deployed via the Veeam console and used with a backup repositoy
all that you need to manage on a node is the service and any setting you wish
to override in the `veeam.ini` file.

To do this create a profile (or some other manifest) like this:

```puppet
# Veeam agent management
class profiles::backup (
  Hash $config_entries = {},
  Boolean $package_manage = false,
  Boolean $repo_manage = false,
  Boolean $service_manage = false,
  ) {
  # restrict to physical hosts since agents aren't generally needed in VM's
  if $facts['is_virtual'] == false {
    # As support for other os families is still in the works we need to further
    # restrict how this is applied
    case $facts['kernel'] {
      'Linux': {
        if $facts['os']['family'] == 'RedHat' {
          class { 'veeamagent':
            config_entries => $config_entries,
            package_manage => $package_manage,
            repo_manage    => $repo_manage,
            service_manage => $service_manage,
          }
        } else {
          class { 'veeamagent':
            config_entries => $config_entries,
            package_manage => false, # not yet supported outside the RedHat family
            repo_manage    => false, # not yet supported outside the RedHat family
            service_manage => $service_manage,
          }
        }
      } # end Linux
      # more kernels to come...
    } # end kernel case
  } # end if physical
}
```

This will, by default, do nothing to the hosts its applied to. You can alter
this behaviour easily via hiera in a node file (or similar). Note: the format
of the hash is described in the `veeam_agent_config` type below.

```yaml
---
# set to use the common snapshot type and store data in /veeam-snapshot-space
profiles::backup::config_entries:
  'snapshot/location':
    value: '/veeam-snapshot-space'
  'snapshot/type':
    value: 'common'

# enable service management to make sure the agent stays available
profiles::backup::service_manage: true
```

### Create a local repository and backup job

This example will install Veeam, create a backup repository located at
`/backups`, and create a backup job to run every Monday at 22:00 (10 PM).
No metaparameters are needed because the module will always create backup
repos before backup jobs.

```puppet
veeamagent::backup_repo { 'Backup Repo':
  location => '/backups',
}

veeamagent::backup_job { 'Backup Job':
  repo_name  => 'Backup Repo',
  run_hour   => 22,
  run_minute => 00,
  run_monday => true,
}
```

### Create a backup job for use with a Veeam Backup & Replication repository

This example will create the same backup job as above, except the `repo_name`
parameter points to a Veeam Backup & Replication repository.

```puppet
veeamagent::backup_job { 'Backup Job':
  repo_name          => 'VBR Backups',
  run_hour           => 22,
  run_minute         => 00,
  run_monday         => true,
  vbrserver_login    => 'username',
  vbrserver_domain   => 'DOMAIN',
  vbrserver_fqdn     => 'veeam01.localdomain',
  vbrserver_password => 'password',
}
```

### Go a step further with Profiles and Hiera usage

The example below will set default values for all backup job resources.
Once the profile is included for a node then you can override parameters,
such as backup time, at the node level.

Create a backup profile:

```puppet
# Servers backups profile
class profiles::backup {
  $backup_jobs     = lookup('backup_jobs', Any, 'hash', undef)
  $backup_defaults = lookup('backup_defaults', Any, 'hash', undef)

  create_resources('veeamagent::backup_job', $backup_jobs, $backup_defaults)
}
```

Set defaults in the highest, or most appropriate, level of the hierarchy.
This example uses a Veeam Backup & Replication repository, keeps 32 backup
points, and backs up every day of the week:

```yaml
---
backup_defaults:
  repo_name          : 'VBR Backups'
  max_points         : 32
  run_sunday         : true
  run_monday         : true
  run_tuesday        : true
  run_wednesday      : true
  run_thursday       : true
  run_friday         : true
  run_saturday       : true
  vbrserver_login    : 'username'
  vbrserver_domain   : 'DOMAIN'
  vbrserver_fqdn     : 'veeam01.localdomain'
  vbrserver_password : 'password'
```

Now simply set the backup time with 3 lines of Puppet code at the node level:

```yaml
---
backup_jobs:
  Backup Job:
    run_hour   : 22
    run_minute : 00
```

You could also backup twice a day using the same method:

```yaml
---
backup_jobs:
  Morning Backup:
    run_hour   : 6
    run_minute : 00
  Evening Backup:
    run_hour   : 18
    run_minute : 00
```

## Reference

### Types

#### `veeam_agent_config`

Manages entries in `veeam.ini`. Optionally, unmanaged settings can be purged.
If deploying agents via the console then purging resources is not recommended
for a host without first verifying that you've captured any settings set during
the deployment.

Resource title: formatted as 'section/setting'

Parameters:

* `ensure`: can be set to present or absent
* `value`: this is what comes after the `=` of the setting

You can utilize `puppet resource veeam_agent_config --to_yaml` to capture any
existing values in your `veeam.ini` for use in hiera.

Example hiera entry to set two values and remove a third:

```yaml
---
veeamagent::config_entries:
  'bitlooker/exclude':
    value: '/dev/sda1, /dev/sdb3'
  'general/logsRotateDays':
    value: '7'
```

If changing the same entries directly within a manifest you can use
`create_resources` like so:

```puppet
$settings = {
  'bitlooker/exclude' => {
    value => '/dev/sda1, /dev/sdb3'
  },
  'general/logsRotateDays' => {
    value => '7'
  },
  'snapshot/type' => {
    ensure => absent
  }
}

create_resources(veeam_agent_config, $settings)
```

Example of purging unmanaged entries:

```puppet
resources { 'veeam_agent_config'
  purge => true,
}
```

### Classes

#### Public classes

* `veeamagent`: Main class, includes all other classes.

### Private classes

* `veeamagent::preinstall`: Handles the package repository, if applicable.
* `veeamagent::install`: Handles the packages.
* `veeamagent::config`: Handles the main configuration file.
* `veeamagent::service`: Handles the service.

### Defines

#### Public defined types

* `veeamagent::backup_job`: Handles backup jobs.
* `veeamagent::backup_repo`: Handles backup repos.

### Parameters - Class: veeamagent

#### `config_entries`

Optional.

Data type: Hash.

Defines a set of entries for the veeam.ini file.

Default value: {}.

#### `gpgkey_ca_ensure`

Data type: String

Ensure value for the local Veeam CA GPG keys.

Default value: varies by operating system.

#### `gpgkey_ca_local`

Data type: String

Path to the local Veeam CA GPG Key.

Default value: varies by operating system.

#### `gpgkey_ca_source`

Data type: String

Path to the remote Veeam CA GPG Key.

Default value: varies by operating system.

#### `gpgkey_ensure`

Data type: String

Ensure value for the local Veeam GPG keys.

Default value: varies by operating system.

#### `gpgkey_local`

Data type: String

Path to the local Veeam GPG Key.

Default value: varies by operating system.

#### `gpgkey_source`

Data type: String

Path to the remote Veeam GPG Key.

Default value: varies by operating system.

#### `package_ensure`

Data type: String

Ensure value for the Veeam package.

Default value: `present`.

#### `package_manage`

Data type: Boolean

Whether to manage the Veeam package.

Default value: `true`.

#### `package_name`

Data type: Array[String]

Name for the Veeam package.

Default value: varies by operating system.

#### `repo_manage`

Data type: Boolean

Whether to manage the Veeam package repository.

Default value: `true`.

#### `repo_path`

Data type: String

Path to where package repositoy files are located.

Default value: varies by operating system.

#### `repo_template`

Data type: String

Path to a template for the Veeeam package repository.

Default value: `'veeamagent/veeam-repo.epp'`.

#### `service_enable`

Data type: Boolean

Whether to enable the Veeam service.

Default value: `true`.

#### `service_ensure`

Data type: String

Ensure value for the Veeam service.

Default value: `running`.

#### `service_name`

Data type: String

Name of the Veeam service.

Default value: varies by operating system.

### Parameters - Define: veeamagent::backup_repo

#### `ensure`

Data type: Enum['absent', 'present']

Ensure value for a backup repository.

Default value: `present`.

#### `location`

Data type: String

Location to create a Veeam repository (local path).

Default value: ''.

#### `veeamcmd_path`

Data type: Array[String]

Path to the `veeam` commands. Shared between Define: `backup_repo` and Define: `backup_job`.

Default value: varies by operating system.

### Parameters - Define: veeamagent::backup_job

#### `block_size`

Data type: String

Data block size (in kilobytes).

Default value: `KbBlockSize1024`.

#### `compression_type`

Data type: String

Data compression level.

Default value: `Lz4`.

#### `config_dir`

Data type: String

Location of Veeam configuration files.

Default value: varies by operating system.

#### `enable_dedup`

Data type: Boolean

Whether to eneble deduplication.

Default value: `true`.

#### `enabled`

Data type: Boolean

Whether the job is enebled to run.

Default value: `true`.

#### `ensure`

Data type: Enum['absent', 'present']

Whether the job should exist.

Default value: `present`.

#### `index_all`

Data type: Boolean

Defines that Veeam Agent for Linux must index all files on the volumes included in backup.

Default value: `false`.

#### `max_points`

Data type: Integer

The number of restore points that you want to store in the backup location.

Default value: `14`.

#### `object_type`

Data type: String

The type of backup job to create.

Default value: `AllSystem`.

#### `object_value`

Optional.

Data type: String

Files or directories that apply to the `record_type`.

Default value: ''.

#### `post_jobcommand`

Optional.

Data type: String

Path to the script that should be executed after the backup job completes.

Default value: ''.

#### `post_thawcommand`

Optional.

Data type: String

Path to the script that should be executed after the snapshot creation. This option is available only if Veeam Agent for Linux operates in the server mode.

Default value: ''.

#### `pre_freezecommand`

Optional.

Data type: String

Path to the script that should be executed before the snapshot creation.
This option is available only if Veeam Agent for Linux operates in the server mode.

Default value: ''.

#### `pre_jobcommand`

Optional.

Data type: String

Path to the script that should be executed at the start of the backup job.

Default value: ''.

#### `record_type`

Data type: String

Whether to include or exclude `object_value` for the backup jobs.

Default value: `Include`.

#### `repo_name`

Data type: String

Name of the repository to where the backups will be saved.

Default value: `undef`.

#### `retry_count`

Data type: Integer

Number of times to retry the backup job.

Default value: `3`.

#### `run_friday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Fridays.

Default value: `false`.

#### `run_hour`

Optional.

Data type: String

What hour, in 24 hour time, to schedule the backup job to run.

Default value: ''.

#### `run_minute`

Optional.

Data type: String

What minute to schedule the backup job to run.

Default value: ''.

#### `run_monday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Mondays.

Default value: `false`.

#### `run_saturday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Saturdays.

Default value: `false`.

#### `run_sunday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Sundays.

Default value: `false`.

#### `run_thursday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Thursdays.

Default value: `false`.

#### `run_tuesday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Tuesdays.

Default value: `false`.

#### `run_wednesday`

Optional.

Data type: Boolean

Whether to schedule the backup job to run on Wednesdays.

Default value: `false`.

#### `vbrserver_domain`

Data type:

The domain of the user account used to connect to the Veeam Backup & Replication server.

Default value: ''.

#### `vbrserver_fqdn`

Optional.

Data type: String

The fully qualified domain name of the Veeam Backup & Replication server.

Default value: ''.

#### `vbrserver_login`

Optional.

Data type: String

The name of the user account used to connect to the Veeam Backup & Replication server.

Default value: ''.

#### `vbrserver_password`

Optional.

Data type: String

The password of the user account used to connect to the Veeam Backup & Replication server.

Default value: ''.

#### `vbrserver_port`

Optional.

Data type: String

The port used to connect to the Veeam Backup & Replication server.

Default value: `10002`.

#### `veeamcmd_path`

Data type: Array[String]

Path to the `veeam` commands. Shared between Define: `backup_repo` and Define: `backup_job`.

Default value: varies by operating system.

## Limitations

This module is currently only campatible with Linux on the RedHat family but support and compatibility will be expanded in the future.

This module does not manage backup jobs and repositories created outside of the module.

There are also several other limitations to solve noted in the open issue [#1](https://github.com/thespain/thespain-veeamagent/issues/1) for this module to reach release 1.0.0.

## Development

### Contributing

Pull requests are welcome!

#### Contributors

Gene Liverman (@genebean) - Added types and reworked for compitibilty with agents deployed by the Veeam console. Also proofread and updated documentation, added enhancements to testing.

### Testing

This project contains a Vagrantfile for automated testing using [rspec-puppet](http://rspec-puppet.com).

#### Testing quickstart:

```shell
vagrant up
vagrant ssh
export PUP_MOD=veeamagent; rsync -rv --delete /vagrant/ /home/vagrant/$PUP_MOD --exclude bundle; cd /home/vagrant/$PUP_MOD; bundle install --jobs=3 --retry=3; bundle exec rake tests
```

## License

This module is released under the BSD 3-Clause "New" or "Revised" License.

By installing Veeam Agent for Linux or Veeam Agent for Microsoft Windows you accept the Veeam End User License Agreement located at http://www.veeam.com/eula.html.
