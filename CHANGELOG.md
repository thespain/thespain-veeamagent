[![GitHub tag](https://img.shields.io/github/tag/thespain/thespain-veeamagent.svg)](https://github.com/thespain/thespain-veeamagent)

## 2019-04-12 Release 1.0.0
- **Breaking changes:**
    - Removed all veeam agent config file related parameters (`veeam.ini`) in favor of new type/provider. Please migrate any custom settings to use `veeam_agent_config` as described in the README (See enhancement below).

- **Implemented enhancements:**
    - Added `veeam_agent_config` type and provider for managing the veeam agent config file (Thanks to Gene Liverman).
    - Added dependency for module puppetlabs-inifile
    - Added Puppet 6 support

## 2017-08-24 Release 0.3.0
- Added enhancements to testing (Thanks to Gene Liverman).

## 2017-08-06 Release 0.2.2
- Fixed changelog and another Travis CI issue.

## 2017-08-06 Release 0.2.1
- Fixed an issue with the Travis CI file.

## 2017-08-06 Release 0.2.0
- Proofread and updated documentation (Thanks to Gene Liverman).

## 2017-08-04 Release 0.1.2
- Fixed badges in Readme and Changelog.

## 2017-08-04 Release 0.1.1
- No changes. User error when releaseing with `puppet-blacksmith`.

## 2017-08-04 Release 0.1.0
- First working version with RedHat osfamily.