# veeamagent/lib/puppet/provider/veeam_agent_config/ini_setting.rb
Puppet::Type.type(:veeam_agent_config).provide(
  :ini_setting,
  # set ini_setting as the parent provider
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do
  # hard code the separator to the one used in the stock veeam.ini
  def separator
    '= '
  end
  # implement section as the first part of the namevar
  def section
    resource[:name].split('/', 2).first
  end
  def setting
    # implement setting as the second part of the namevar
    resource[:name].split('/', 2).last
  end
  # hard code the file path (this allows purging)
  def self.file_path
    '/etc/veeam/veeam.ini'
  end
end
