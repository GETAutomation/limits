# Puppet module: limits

This is a Puppet module for limits
It provides only package installation and file configuration.


## USAGE - Basic management

* Install limits with default settings

        class { 'limits': }

* Install a specific version of limits package

        class { 'limits':
          version => '1.0.1',
        }

* Remove limits resources

        class { 'limits':
          absent => true
        }

* Enable auditing without without making changes on existing limits configuration *files*

        class { 'limits':
          audit_only => true
        }

* Module dry-run: Do not make any change on *all* the resources provided by the module

        class { 'limits':
          noops => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { 'limits':
          source => [ "puppet:///modules/get-automation/limits/limits.conf-${hostname}" , "puppet:///modules/get-automation/limits/limits.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { 'limits':
          source_dir       => 'puppet:///modules/get-automation/limits/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file. Note that template and source arguments are alternative. 

        class { 'limits':
          template => 'get-automation/limits/limits.conf.erb',
        }

* Automatically include a custom subclass

        class { 'limits':
          extend => 'get-automation::my_limits',
        }



## TESTING
[![Build Status](https://travis-ci.org/get-automation/puppet-limits.png?branch=master)](https://travis-ci.org/get-automation/puppet-limits)
