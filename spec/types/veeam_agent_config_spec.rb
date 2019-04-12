require 'spec_helper'

describe 'veeam_agent_config' do
  let(:title) { 'section_foo/setting_bar'}
  it { is_expected.to be_valid_type }
  it { is_expected.to be_valid_type.with_provider(:ini_setting) }
  it { is_expected.to be_valid_type.with_parameters('name') }
  it { is_expected.to be_valid_type.with_properties('value') }
end
