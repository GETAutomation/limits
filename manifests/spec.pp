# = Class: limits::spec
#
# This class is used only for rpsec-puppet tests
# Can be taken as an example on how to do custom classes but should not
# be modified.
#
# == Usage
#
# This class is not intended to be used directly.
# Use it as reference
#
class limits::spec inherits limits {

  # This just a test to override the arguments of an existing resource
  # Note that you can achieve this same result with just:
  # class { "limits": template => "limits/spec.erb" }

  File['limits.conf'] {
    content => template('limits/spec.erb'),
  }

}

# vim: ts=2 et sw=2 autoindent
