require 'spec_helper'
describe 'veeamagent::service' do
  on_supported_os.each do |os, facts|
    context "on #{os} with defaults" do
      let(:facts) do
        facts
      end

      it { is_expected.to contain_service('veeamservice') \
      .with(:ensure => 'running', :enable => true,) }
    end
  end
end