#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::Interface::Fs::SSHAny;
   
use strict;
use warnings;

use Fcntl;
use Rex::Interface::Exec;
use Rex::Interface::Fs::Base;
use base qw(Rex::Interface::Fs::Base);

require Rex::Commands;

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $self = $proto->SUPER::new(@_);

   bless($self, $proto);

   return $self;
}

sub ls {
}

sub is_dir {
}

sub is_file {
}

sub unlink {
}

sub mkdir {
}

sub stat {
}

sub is_readable {
}

sub is_writable {
}

sub readlink {
}

sub rename {
}

sub glob {
}

sub upload {
}

sub download {
}

1;
