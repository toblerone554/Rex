#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

use strict;

package Rex::Inventory::SMBios::MemoryArray;

use warnings;

use Rex::Inventory::SMBios::Section;
use base qw(Rex::Inventory::SMBios::Section);

__PACKAGE__->section("physical memory array");

__PACKAGE__->has(
  [
    { key => 'Number Of Devices',     from => "Number of Slots/Sockets" },
    { key => 'Error Correction Type', from => "ECC" },
    { key => 'Maximum Capacity',      from => "Max Capacity" },
    'Location',
  ],
  1
);

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = $that->SUPER::new(@_);

  bless( $self, $proto );

  return $self;
}

1;

