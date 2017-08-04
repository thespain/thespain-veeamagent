require 'spec_helper'
describe 'veeamagent::preinstall' do
  on_supported_os.each do |os, facts|
    context "on #{os} with defaults" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'RedHat'
        it { is_expected.to contain_file('/etc/yum.repos.d/veeam.repo') \
        .with_content(/baseurl=http:\/\/repository.veeam.com\/backup\/linux\/agent\/rpm\/el\/(6|7)\/\$basearch/) }
        it { is_expected.to contain_yum__gpgkey('/etc/pki/rpm-gpg/RPM-GPG-KEY-VeeamSoftwareRepo') }
        it { is_expected.to contain_yum__gpgkey('/etc/pki/rpm-gpg/VeeamSoftwareRepo') }
      end
    end

    context "on #{os} with repo_manage disabled" do
      let(:pre_condition) { 'class {"::veeamagent": repo_manage => false}' }

       it { is_expected.not_to contain_file('/etc/yum.repos.d/veeam.repo') }
    end
  end
end