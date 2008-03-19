package App::MadEye::Plugin::Agent::SNMP::Process;
use strict;
use warnings;
use App::MadEye::Plugin::Agent::Base;
use Net::SNMP;

my $hrSWRunPath = '.1.3.6.1.2.1.25.4.2.1.4';

sub is_dead {
    my ($self, $host) = @_;

    my $process   = $self->config->{config}->{process}   or die "missing process";

    my $response = $self->snmp_session(
        $host => sub {
            my $session = shift;
            my $response = $session->get_table(
                -baseoid => $hrSWRunPath,
            ) or die "cannot get a $_ : " . $session->error;
            return $response;
        }
    );

    my $process_cnt = scalar grep { $_ eq $process } values %$response;

    App::MadEye->context->log(debug => "$host has $process_cnt $process");

    if ($process_cnt > 0) {
        return; # alive
    } else {
        return $process_cnt;
    }
}

sub snmp_session {
    my ($self, $host, $callback, ) = @_;

    my $community = $self->config->{config}->{community} or die "missing community";
    my $port      = $self->config->{config}->{port}    || 161;
    my $timeout   = $self->config->{config}->{timeout} || 10;

    my ($session, $error) = Net::SNMP->session(
        -hostname  => $host,
        -community => $community,
        -port      => $port,
        -timeout   => $timeout,
    );

    if (not defined($session)) {
        die "ERROR: $error.\n";
    } else {
        my $response = $callback->($session);
        $session->close();
        return $response;
    }
}

1;
__END__

=head1 NAME

App::MadEye::Plugin::Agent::SNMP::Process - monitoring process

=head1 SCHEMA

    type: map
    mapping:
        target:
            type: seq
            required: yes
            sequence:
                - type: str
        community:
            required: yes
            type: str
        port:
            required: no
            type: int
        timeout:
            required: no
            type: int
        process:
            required: yes
            type: str

=head1 AUTHORS

Tokuhiro Matsuno

=head1 SEE ALSO

L<Net::SNMP>, L<App::MadEye>

