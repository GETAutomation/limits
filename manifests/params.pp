# = Class: limits::params
#
# This class defines default parameters used by the main module class limits
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to limits class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class limits::params {

  # Define what operating systems does this module support.
  # Anything not listed as true will prevent the module from being applied.
  $supported_os = $::operatingsystem ? {
    /(?i:RedHat|OracleLinux|CentOS)/  => true,
    /(?i:Debian|Ubuntu)/              => false,
    default                           => false
  }

  ### Application related parameters ###
  # - Package
  $package = $::operatingsystem ? {
    default => 'pam',
  }

  $version = $::operatingsystem ? {
    default => 'present'
  }

  # - File
  $config_dir = $::operatingsystem ? {
    default => '/etc/security',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/security/limits.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }


  ### General Settings
  $noops            = false
  $audit_only       = false
  $absent           = false
  $extend           = ''

  # Config File Parameters
  $source                    = ''
  $source_dir                = ''
  $source_dir_purge          = false
  $template                  = undef
  $content                   = undef
  $options                   = undef

}

# vim: ts=2 et sw=2 autoindent
