# = Class: limits
#
# This is the main limits class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behavior and customizations
#
# [*extend*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, limits class will automatically "include $extend"
#   Can be defined also by the (top scope) variable $limits_extend
#   Can be defined also by the (class scope) variable $limits::extend
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, limits main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $limits_source
#   Can be defined also by the (class scope) variable $limits::source
#
# [*source_dir*]
#   If defined, the whole limits configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $limits_source_dir
#   Can be defined also by the (class scope) variable $limits::source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $limits_source_dir_purge
#   Can be defined also by the (class scope) variable $limits::source_dir_purge
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, limits main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $limits_template
#   Can be defined also by the (class scope) variable $limits::template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $limits_options
#   Can be defined also by the (class scope) variable $limits::options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#   Can be defined also by the (class scope) variable $limits::version
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $limits_absent
#   Can be defined also by the (class scope) variable $limits::absent
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $limits_audit_only
#   and $audit_only
#   Can be defined also by the (class scope) variable $limits::audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: false
#   Can be defined also by the (class scope) variable $limits::noops
#
# Default class params - As defined in limits::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via *top* scope variables.
#
# [*package*]
#   The name of limits package
#
# [*config_file*]
#   Main configuration file path
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top/class scope level in an ENC (Automaton, Foreman etc..)) and "include limits"
# - Call limits as a parametrized class
#
# See README for details.
#
#
class limits (
  $noops             = $limits::params::noops,
  $extend            = $limits::params::extend,
  $absent            = $limits::params::absent,
  $package           = $limits::params::package,
  $version           = $limits::params::version,
  $config_file       = $limits::params::config_file,
  $config_file_mode  = $limits::params::config_file_mode,
  $config_file_owner = $limits::params::config_file_owner,
  $config_file_group = $limits::params::config_file_group,
  $source            = $limits::params::source,
  $source_dir        = $limits::params::source_dir,
  $source_dir_purge  = $limits::params::source_dir_purge,
  $template          = $limits::params::template,
  $content           = $limits::parmas::content,
  $options           = $limits::params::options,
  ) inherits limits::params {

  ### Warn if Operating System is *NOT* supported by this module
  if $limits::params::supported_os == true {
    ### Validation of Parameters
    validate_absolute_path($config_dir)
    validate_absolute_path($config_file)
    validate_string($config_file_owner)
    validate_string($config_file_group)
    validate_string($config_file_mode)
    if $options { validate_hash($options) }

    # Sanitize Booleans
    $bool_source_dir_purge    = any2bool($limits::source_dir_purge)
    $bool_absent              = any2bool($limits::absent)
    $bool_audit_only          = any2bool($limits::audit_only)
    $bool_noops               = any2bool($limits::noops)

    ### Definition of Managed Resource Parameters ( These are set based off the class parameter input )
    $manage_package = $limits::bool_absent ? {
      true  => 'absent',
      false => $limits::version,
    }

    $manage_file = $limits::bool_absent ? {
      true    => 'absent',
      default => 'present',
    }

    $manage_config_file_content = default_content($limits::content, $limits::template)

    $manage_config_file_source  = $limits::source ? {
      ''      => undef,
      default => is_array($limits::source) ? {
        false   => split($limits::source, ','),
        default => $limits::source,
      }
    }

    $manage_file_replace = $limits::bool_audit_only ? {
       true  => false,
       false => true,
    }

    ### Definition of Metaparameters
    $manage_audit = $limits::bool_audit_only ? {
      true  => 'all',
      false => undef,
    }

    ### Managed resources
    package { 'limits.package':
      ensure  => $limits::manage_package,
      name    => $limits::package,
      noop    => $limits::bool_noops,
    }

    file { 'limits.conf':
      ensure  => $limits::manage_file,
      path    => $limits::config_file,
      mode    => $limits::config_file_mode,
      owner   => $limits::config_file_owner,
      group   => $limits::config_file_group,
      require => Package['limits.package'],
      source  => $limits::manage_config_file_source,
      content => $limits::manage_config_file_content,
      replace => $limits::manage_file_replace,
      audit   => $limits::manage_audit,
      noop    => $limits::bool_noops,
    }

  # The whole limits configuration directory can be recursively overriden by a source directory
    if $limits::source_dir {
      file { 'limits.dir':
        ensure  => directory,
        path    => $limits::config_dir,
        require => Package['limits.package'],
        source  => $limits::source_dir,
        recurse => true,
        purge   => $limits::bool_source_dir_purge,
        force   => $limits::bool_source_dir_purge,
        replace => $limits::manage_file_replace,
        audit   => $limits::manage_audit,
        noop    => $limits::bool_noops,
      }
    }


    ### Include custom class if $extend is set
    if $limits::extend {
      include $limits::extend
    }
  } else {
    notice("INFO: ${::operatingsystem} is _NOT_ supported. Contact module maintainer for support.")
    notify{"INFO: ${::operatingsystem} is _NOT_ supported. Contact module maintainer for support.":}
  }

}


# vim: ts=2 et sw=2 autoindent
