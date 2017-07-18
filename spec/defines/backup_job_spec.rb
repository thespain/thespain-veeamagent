require 'spec_helper'
describe 'veeamagent::backup_job' do
  on_supported_os.each do |os, facts|
    context "on #{os} with example backup job configured" do
      let(:title) { 'Backup Test' }
      let(:facts) do
        facts
      end
    let(:params) do
        { :repo_name  => 'Backup Repository',
          :run_hour   => 0,
          :run_minute => 0,
        }
      end

      it { is_expected.to contain_file('/etc/veeam/Backup Test.xml') \
        .with_content(/<Job Name="Backup Test" creation_time=".*" RepoName="Backup Repository">/) }

      it { is_expected.to contain_exec('Import Backup Job - Backup Test') \
        .with_command('veeamconfig config import --file "/etc/veeam/Backup Test.xml"',) }
    end

    context "on #{os} with VBR Repository" do
      let(:title) { 'Backup Test' }
      let(:facts) do
        facts
      end
    let(:params) do
        { :vbrserver_fqdn => 'veeam01.localdomain',
          :repo_name      => 'Backup Repository',
          :run_hour       => 0,
          :run_minute     => 0,
        }
      end

      it { is_expected.to contain_file('/etc/veeam/Backup Test.xml') \
        .with_content(/<VbrServer Name="veeam01"/) }

      it { is_expected.to contain_file('/etc/veeam/Backup Test.xml') \
        .with_content(/RepoName="\[veeam01\]Backup Repository"/) }

      it { is_expected.to contain_exec('Resync VBR Repos - Backup Test') \
        .with_command('veeamconfig vbrserver resync',) }

      it { is_expected.to contain_exec('Delete vbrserver - Backup Test') \
        .with_command('veeamconfig vbrserver delete --name veeam01 | exit 0',) }
    end

    context "on #{os} without VBR Repository" do
      let(:title) { 'Backup Test' }
      let(:facts) do
        facts
      end
    let(:params) do
        { :repo_name  => 'Backup Repository',
          :run_hour   => 0,
          :run_minute => 0,
        }
      end

      it { is_expected.to contain_file('/etc/veeam/Backup Test.xml') \
        .without_content(/<VbrServer Name="veeam01"/) }

      it { is_expected.to contain_file('/etc/veeam/Backup Test.xml') \
        .with_content(/RepoName="Backup Repository"/) }

      it { is_expected.not_to contain_exec('Resync VBR Repos - Backup Test') }

      it { is_expected.not_to contain_exec('Delete vbrserver - Backup Test') }
    end

    context "on #{os} with example backup job absent" do
      let(:title) { 'Backup Test' }
      let(:facts) do
        facts
      end
    let(:params) do
        { :ensure => 'absent', }
      end

      it { is_expected.to contain_file('/etc/veeam/Backup Test.xml') \
        .with_ensure('absent') }

      it { is_expected.to contain_exec('Delete Backup Job - Backup Test') \
        .with_command('veeamconfig job delete --force --name "Backup Test"',) }
    end
  end
end