#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package Rex::Interface::Connection::SSHAny;
   
use strict;
use warnings;

use Net::SSH::Any;
use Rex::Interface::Connection::Base;
use Data::Dumper;

use base qw(Rex::Interface::Connection::Base);

sub new {
   my $that = shift;
   my $proto = ref($that) || $that;
   my $self = $that->SUPER::new(@_);

   bless($self, $proto);

   return $self;
}

sub connect {
   my ($self, %option) = @_;

   my ($user, $pass, $private_key, $public_key, $server, $port, $timeout, $auth_type, $is_sudo);

   $user    = $option{user};
   $pass    = $option{password};
   $server  = $option{server};
   $port    = $option{port};
   $timeout = $option{timeout};
   $public_key = $option{public_key};
   $private_key = $option{private_key};
   $auth_type   = $option{auth_type};
   $is_sudo     = $option{sudo};

   $self->{is_sudo} = $is_sudo;

   $self->{__auth_info__} = \%option;

   Rex::Logger::debug("Using user: " . $user);
   Rex::Logger::debug("Using password: " . ($pass?"***********":"<no password>"));

   $self->{server} = $server;

   my %auth_option = ();

   if($auth_type && $auth_type eq "pass") {
      %auth_option = (
         user => $user,
         password => $pass,
      );
   }
   elsif($auth_type && $auth_type eq "key") {
      %auth_option = (
         user => $user,
         key_path => $private_key,
         password => ($pass?$pass:"")
      );
   }
   elsif($auth_type && $auth_type eq "try") {
      %auth_option = (
         user       => $user,
         key_path   => ($private_key?$private_key:""),
         passphrase => ($pass?$pass:""),
      );
   }

   my $fail_connect = 0;

   CON_SSH:
      $port    ||= Rex::Config->get_port(server => $server) || 22;
      $timeout ||= Rex::Config->get_timeout(server => $server) || 3;

      $server  = Rex::Config->get_ssh_config_hostname(server => $server) || $server;

      if($server =~ m/^(.*?):(\d+)$/) {
         $server = $1;
         $port   = $2;
      }
      Rex::Logger::info("Connecting to $server:$port (" . $user . ")");

      $self->{ssh} = Net::SSH::Any->new($server, %auth_option);

      if($self->{error}) {
         ++$fail_connect;
         sleep 1;
         goto CON_SSH if($fail_connect < Rex::Config->get_max_connect_fails(server => $server)); # try connecting 3 times

         Rex::Logger::info("Can't connect to $server", "warn");

         $self->{connected} = 0;

         return;
      }
      else {
         $self->{connected} = 1;
         $self->{auth_ret}  = 1;
      }

   $self->{sftp} = $self->{ssh}->sftp;
}

sub reconnect {
   my ($self) = @_;
   Rex::Logger::debug("Reconnecting SSH");

   $self->connect(%{ $self->{__auth_info__} });
}

sub disconnect {
   my ($self) = @_;
   return $self->{ssh} = undef;
}

sub error {
   my ($self) = @_;
   return $self->get_connection_object->error;
}

sub get_connection_object {
   my ($self) = @_;
   return $self->{ssh};
}

sub get_fs_connection_object {
   my ($self) = @_;
   return $self->{sftp};
}

sub is_connected {
   my ($self) = @_;
   return $self->{connected};
}

sub is_authenticated {
   my ($self) = @_;
   return $self->{auth_ret};
}

sub get_connection_type {
   my ($self) = @_;

   my $type = "SSHAny";

   return $type;
}


1;
