require 'spec_helper'
describe 'veeamagent' do
  context 'with default values for all parameters' do
    it { should contain_class('veeamagent') }
  end
end
