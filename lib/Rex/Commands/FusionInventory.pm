#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::Commands::FusionInventory;
   
use strict;
use warnings;
   
use FusionInventory::Agent;
use Rex::Logger;

require Exporter;
use base qw(Exporter);
use vars qw(@EXPORT);
    
@EXPORT = qw(fusion);
   

sub fusion {

   my $options = {"local" => "/tmp",};

   Rex::Logger::debug("Trying to run fusioninventory");

   eval {
       my $agent = FusionInventory::Agent->new(
           confdir => './',
           datadir => '/tmp',
           vardir  => '/tmp',
           options => $options
       );
       $agent->run();
   };

   if ($@) {
       print STDERR "Execution failed. Are you sure the software is fully ";
       print STDERR "installed\n";
       print STDERR "and an old version of the agent not already present on the ";
       print STDERR "system?\n";
       print STDERR "___\n";
       print STDERR $@;
       exit 1;
   }

}
   
1;
