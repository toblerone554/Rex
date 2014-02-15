#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   

package Rex::Interface::Shell::Bash;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {};
    $self->{path} = undef;
    bless($self, $class);
    
    return $self;
}

sub path {
    my ($self, $path ) = @_;
    $self->{path} = $path;
}

sub source_global_profile {
    my ($self, $parse) = @_;
    $self->{source_global_profile} = $parse;
}

sub source_profile {
    my ($self, $parse) = @_;
    $self->{source_profile} = $parse;
}

sub set_locale {
    my ($self, $locale) = @_;
    $self->{locale} = $locale;
}

sub exec {
    my ($self, $cmd, $option) = @_;
    my $complete_cmd = $cmd;

    if(exists $option->{path}) {
      $self->path($option->{path});
    }

    my $env_string = "";

    if(my $env = $self->get_env) {
      for my $key (keys %{ $env }) {
         $env_string .= "$key=$env->{$key} "
      }
    }

    my $prefix_cmd = "";

    if(exists $option->{cwd}) {
        $prefix_cmd = "cd $option->{cwd}; ";
    }

    if ($self->{path}) {
        $prefix_cmd = "PATH=$self->{path}; export PATH; $prefix_cmd ";
    }

    if ($self->{locale} && ! exists $option->{no_locales}) {
        $prefix_cmd = "LC_ALL=$self->{locale} ; export LC_ALL; $prefix_cmd ";
    }

    if ($self->{source_profile}) {
        $prefix_cmd = ". ~/.profile >/dev/null 2>&1 ; $prefix_cmd ";
    }


    if ($self->{source_global_profile}) {
        $prefix_cmd = ". /etc/profile >/dev/null 2>&1 ; $prefix_cmd ";
    }

# this is due to a strange behaviour with Net::SSH2 / libssh2
# it may occur when you run rex inside a kvm virtualized host connecting to another virtualized vm on the same hardware
    if(Rex::Config->get_sleep_hack) {
      $complete_cmd .= " ; f=\$? ; sleep .00000001 ; exit \$f";
    }

    if(exists $option->{preprocess_command} && ref $option->{preprocess_command} eq "CODE") {
      $complete_cmd = $option->{preprocess_command}->($complete_cmd);
    }

    if(exists $option->{format_cmd}) {
      $complete_cmd = "$env_string $complete_cmd";
      $option->{format_cmd} =~ s/{{CMD}}/$complete_cmd/;
      $complete_cmd = $option->{format_cmd};
      $env_string = "";
    }

    return "$prefix_cmd $env_string $complete_cmd";
}

sub set_env {
   my ($self, $env) = @_;
   $self->{__env__} = $env;
}

sub get_env {
   my ($self) = @_;
   return $self->{__env__};
}

1;
