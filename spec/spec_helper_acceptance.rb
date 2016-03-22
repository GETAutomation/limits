require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end


RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.join(File.dirname(__FILE__), '..'), '..'))
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    ['getlib','stdlib'].each do |module_name|
      module_dir = "#{proj_root}/#{module_name}"
      puppet_module_install(:source => module_dir, :module_name => module_name)
    end
    hosts.each do |host|
      shell("/bin/touch #{default['puppetpath']}/hiera.yaml")
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
    puppet_module_install(:source => module_root, :module_name => 'limits')
  end
end
