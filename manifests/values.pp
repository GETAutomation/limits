# = Define: $limits::values
#
# With this define you can manage any limits.conf file
#
# == Parameters
#
# [*domain*]
#   One of the field in the /etc/security/limits.conf file with domain @username and @groupname
#
# [*type*]
#   One of the field in the /etc/security/limits.conf file with type hard and soft
#
# [*item*]
#   One of the field in the /etc/security/limits.conf file with items nproc,core,fsize,maxlogins etc
#
# [*value*]
#   One of the field in the /etc/security/limits.conf file with some values 
#
# [*context*]
#   Path to the destination file
#
# [*path_item*][*path_exact*][*path_other*]
#   Compares domain,type,item,values with the values in the limits.conf file
#
# [*key*]
#   Holds domain/type/item, used as interpolation variable

define limits::values(
   $domain       = undef, 
   $type         = undef, 
   $item         = undef, 
   $value        = undef,
   $key          = "$domain/$type/$item",
   $context      = '/files/etc/security/limits.conf',
   $path_item    = "domain[. = \"$domain\"][type = \"$type\" and item = \"$item\"]",
   $path_exact   = "domain[. = \"$domain\"][type = \"$type\" and item = \"$item\" and value = \"$value\"]",
   $path_other   = "domain[. = \"$domain\"][type = \"$type\" and item = \"$item\" and value != \"$value\"]",
)  {
    
   include limits
   
   ## Parameter Validation and Management
   $manage_context    = pickx($context, "/files/${limits::config_file}")
   
   ## Managed Resources
   augeas { "limits.conf/${key}/eof":
      context => $manage_context,
      onlyif  => 'match #comment[. =~ regexp("End of file")] size > 0',
      changes => 'rm #comment[. =~ regexp("End of file")]',
   }

   augeas { "limits.conf/${key}/rm":
      context => $manage_context,
      onlyif  => "match $path_other size > 0",
      changes => "rm $path_item",
      before  => Augeas["limits.conf/${key}/add"],
   }

   augeas { "limits.conf/${key}/add":
      context => $manage_context,
      onlyif  => "match $path_exact size == 0",
      changes => [
        "set domain[last()+1] $domain",
        "set domain[last()]/type $type",
        "set domain[last()]/item $item",
        "set domain[last()]/value $value"
      ]
   }

}
