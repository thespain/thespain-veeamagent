require 'spec_helper'
describe 'veeamagent::config' do
  on_supported_os.each do |os, facts|
    context "on #{os} with custom settings" do
      let(:pre_condition) {
        'class { "veeamagent":
           config_entries => { "backup/cluster_align" => { value => 5 }},
        }'
      }

      let(:facts) do
        facts
      end

      case facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_veeam_agent_config('backup/cluster_align') \
        .with_value(5) }
      end
    end
  end
end
