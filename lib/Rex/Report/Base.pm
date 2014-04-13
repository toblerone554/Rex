#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::Report::Base;

use strict;
use warnings;

use Data::Dumper;
use Rex::Logger;
use Time::HiRes qw(time);

sub new {
  my $that  = shift;
  my $proto = ref($that) || $that;
  my $self  = {@_};

  bless( $self, $proto );

  $self->{__reports__}          = {};
  $self->{__current_resource__} = "";

  return $self;
}

sub report {
  my ( $self, %option ) = @_;

  #  push @{$self->{__reports__}}, $msg;
  $self->{__reports__}->{ $self->{__current_resource__} }->{changed} =
    $option{changed} || 0;

  push @{ $self->{__reports__}->{ $self->{__current_resource__} }->{messages} },
    $option{message} || "Nothing changed.";
}

sub report_task_execution {
  my ( $self, %option ) = @_;
  $self->{__reports__}->{task} = \%option;
}

sub report_resource_start {
  my ( $self, %option ) = @_;

  if ( $self->{__current_resource__} ) {
    Rex::Logger::debug("Another resource is in progress.");
    return;
  }

  if ( exists $self->{__reports__}->{ $self->{__current_resource__} } ) {
    Rex::Logger::info(
      "Multiple definitions of the same resource found. ($self->{__current_resource__})",
      "warn"
    );
  }

  $self->{__current_resource__} = $option{type} . "[" . $option{name} . "]";
  $self->{__reports__}->{ $self->{__current_resource__} } = {
    changed    => 0,
    messages   => [],
    start_time => time,
  };
}

sub report_resource_end {
  my ( $self, %option ) = @_;
  $self->{__reports__}->{ $self->{__current_resource__} }->{end_time} = time;
  $self->{__current_resource__} = "";
}

sub report_resource_failed {
  my ( $self, %opt ) = @_;
  $self->{__reports__}->{__current_resource__}->{failed} = 1;
  push @{ $self->{__reports__}->{__current_resource__}->{messages} },
    $opt{message};
}

sub write_report {
  my ($self) = @_;
  print Dumper $self->{__reports__};
}

1;
