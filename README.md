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

**Linux Users Only:** A kernel module called [veeamsnap](https://github.com/veeam/veeamsnap) will be installed as
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

To install the agent without any backup jobs or repos simply `include ::veeamagent`.

## Usage

### Create a local repository and backup job

This example will install Veeam, create a backup repository located at
`/backups`, and create a backup job to run every Monday at 22:00 (10 PM).
No metaparameters are needed because the module will always create backup
repos before backup jobs.

```puppet
::veeamagent::backup_repo { 'Backup Repo':
  location => '/backups',
}

::veeamagent::backup_job { 'Backup Job':
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
::veeamagent::backup_job { 'Backup Job':
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
  
  create_resources('::veeamagent::backup_job', $backup_jobs, $backup_defaults)
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

#### `bitlooker_enabled`

Optional.

Data type: Boolean.

Allow to disable bitlooker.

Default value: ''.

#### `cluster_align`

Optional.

Data type: Integer

Backup cluster alignment logarithm.

Default value: ''.

#### `config_ensure`

Data type: String

Ensure value for the main Veeam config file.

Default value: `present`.

#### `config_path`

Data type: String

The path to where the main Veeam config files should be stored.

Default value: varies by operating system.

#### `cpu_priority`

Optional.

Data type: Integer

CPU priority for veeamagents, from 0 to 19.

Default value: ''.

#### `db_path`

Optional.

Data type: String

Veeam database path.

Default value: ''.

#### `db_schemepath`

Optional.

Data type: String

Veeam database scheme path.

Default value: ''.

#### `db_schemeupgradepath`

Optional.

Data type: String

Veeam database upgrade scheme path.

Default value: ''.

#### `freepercent_limit`

Optional.

Data type: Integer

Percent of free space on block device can be used for snapshot data allocating.

Default value: ''.

#### `freezethawfailure_ignore`

Optional.

Data type: Boolean

Ignore freeze and thaw scripts result.

Default value: ''.

#### `freezethaw_timeout`

Optional.

Data type: Integer

Timeout for freeze and thaw scripts.

Default value: ''.

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

#### `inactivelvm_ignore`

Optional.

Data type: Boolean

Ignore inactive LVM logical volumes during backup.

Default value: ''.

#### `iorate_limit`

Optional.

Data type: Integer

IO rate limit, from 0.01 to 1.0.

Default value: ''.

#### `job_retries`

Optional.

Data type: Integer

New job default retries count.

Default value: ''.

#### `job_retryallerrors`

Optional.

Data type: Boolean

Retry all errors, set to 'false' to enable retries only for 'snapshot overflow'.

Default value: ''.

#### `log_debuglevel`

Optional.

Data type: Integer

Kernel log logging level. 7 - list all messages as an error, 4 or 0 - all messages as a warning, 2 - all message as a trace (use only if veeam works perfectly on your system).

Default value: ''.

#### `log_dir`

Optional.

Data type: String

Logs path.

Default value: ''.

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

#### `prepost_timeout`

Optional.

Data type: Integer

Timeout for pre- and post-backup scripts.

Default value: ''.

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

#### `snapshot_location`

Optional.

Data type: String

Location folder for snapshot data, only for 'stretch' and 'common' snapshot.

Default value: ''.

#### `snapshot_maxsize`

Optional.

Data type: Integer

Maximum possible snapshot data size, not for stretch snapshot.

Default value: ''.

#### `snapshot_minsize`

Optional.

Data type: Integer

Minimal possible snapshot data size, not for stretch snapshot.

Default value: ''.

#### `snapshot_type`

Optional.

Data type: String

Snapshot data type, can be 'stretch' (default) or 'common'.

Default value: ''.

#### `socket_path`

Optional.

Data type: String

Service socket.

Default value: ''.

#### `stretchsnapshot_portionsize`

Optional.

Data type: Integer

Stretch snapshot data portion.

Default value: ''.

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

This module is currently only campatible with Linux on the RedHat osfamily but support and compatibility will be expanded in the future.

This module does not manage backup jobs and repositories created outside of the module.

There are also several other limitations to solve noted in the open issue [#1](https://github.com/thespain/thespain-veeamagent/issues/1) for this module to reach release 1.0.0.

## Development

### Contributing

Pull requests are welcome!

#### Contributors

Gene Liverman (@genebean) - Proofread and updated documentation, added enhancements to testing.

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
