require 'spec_helper'
describe 'veeamagent::config' do
  on_supported_os.each do |os, facts|
    context "on #{os} with custom settings" do
      let(:pre_condition) { 'class {"::veeamagent": cluster_align => 5}' }
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'RedHat'
        it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
        .with_content(/clusterAlign= 5/) }
      end
    end
  end
end