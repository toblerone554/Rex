#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::Interface::File::SSHAny;
   
use strict;
use warnings;

use Fcntl;
use Rex::Interface::Fs;
use Rex::Interface::File::Base;
use base qw(Rex::Interface::File::Base);

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $self = $proto->SUPER::new(@_);

   bless($self, $proto);

   return $self;
}

sub open {
   my ($self, $mode, $file) = @_;
}

sub read {
   my ($self, $len) = @_;
}

sub write {
   my ($self, $buf) = @_;
}

sub seek {
   my ($self, $pos) = @_;
}

sub close {
   my ($self) = @_;
   $self = undef;
}

1;
