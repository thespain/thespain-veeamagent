require 'spec_helper'
describe 'veeamagent::backup_repo' do
  on_supported_os.each do |os, facts|
    context "on #{os} with example backup repo configured" do
      let(:title) { 'Backup Repo' }
      let(:facts) do
        facts
      end
      let(:params) do
        { :location => '/backups', }
      end

      it { is_expected.to contain_exec('Create Repository - Backup Repo') \
        .with_command('veeamconfig repository create --name "Backup Repo" --location "/backups"',) }
    end

    context "on #{os} with example backup repo absent" do
      let(:title) { 'Backup Repo' }
      let(:facts) do
        facts
      end
      let(:params) do
        {   :ensure   => 'absent',
            :location => '/backups',
        }
      end

      it { is_expected.to contain_exec('Delete Repository - Backup Repo') \
        .with_command('veeamconfig repository delete --name "Backup Repo"',) }
    end
  end
end