require 'spec_helper'
describe 'veeamagent::config' do
  on_supported_os.each do |os, facts|
    let(:facts) do
      facts
    end

    context "on #{os}" do
      context 'with agent_version unspecified' do
        let(:pre_condition) { 'class {"veeamagent": }' }

        it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
                        .with_content(/veeam.ini, v2.0.0.400/)
        }
      end

      context 'with agent_version => 1' do
        let(:pre_condition) { 'class {"veeamagent": agent_version => 1}' }

        it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
                        .with_content(/veeam.ini, v1.0.1.364/)
        }

        it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
                        .without_content(/exclude=/)
        }
      end

      context 'with agent_version => 2' do
        let(:pre_condition) { 'class {"veeamagent": agent_version => 2}' }

        it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
                        .with_content(/veeam.ini, v2.0.0.400/)
        }

        it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
                        .with_content(/exclude=/)
        }
      end

      context 'with agent_version => 3' do
        let(:pre_condition) { 'class {"veeamagent": agent_version => 3}' }

        it { is_expected.to compile.and_raise_error(/parameter 'agent_version' expects an Integer\[1, 2\] value/)
        }
      end

      context "with custom settings" do
        #stretchsnapshot_storage_free_percent


        case facts[:os]['family']
        when 'RedHat'
          let(:pre_condition) { "
            class { 'veeamagent':
              cluster_align                        => 5,
              bitlooker_exclude                    => [
                '/dev/sda2',
                '/dev/sdb4',
              ],
              stretchsnapshot_storage_free_percent => 75,
            }"
          }

          it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
          .with_content(/clusterAlign= 5/) }

          it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
          .with_content(/exclude= \/dev\/sda2, \/dev\/sdb4/) }

          it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
          .with_content(/storageFreePercent= 75/) }
        else
          let(:pre_condition) { 'class {"veeamagent": stretchsnapshot_storage_free_percent => 75}' }

          it { is_expected.to contain_file('/etc/veeam/veeam.ini') \
          .with_content(/storageFreePercent= 75/) }
        end
      end
    end
  end
end
