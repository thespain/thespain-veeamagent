require 'spec_helper'
describe 'veeamagent' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('veeamagent') }
      it { is_expected.to contain_class('veeamagent::preinstall') }
      it { is_expected.to contain_class('veeamagent::install') }
      it { is_expected.to contain_class('veeamagent::config') }
      it { is_expected.to contain_class('veeamagent::service') }
    end
  end
end
