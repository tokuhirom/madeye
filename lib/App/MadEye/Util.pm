package App::MadEye::Util;
use strict;
use warnings;
use base qw/Exporter/;

our @EXPORT = qw/timeout get_schema_from_pod snmp_session/;

use Sys::Syslog qw/:DEFAULT/;
use Pod::POM ();
use List::Util qw/first/;
use YAML ();
use Time::HiRes qw/gettimeofday/;
use Net::SNMP;

sub timeout($$&) {    ## no critic.
    my ( $secs, $msg, $code ) = @_;
    App::MadEye->context->log(debug => "run timer: '$msg', $secs");;
    my $last_alarm = 0;
    eval {
        local $SIG{ALRM} = sub { die "Time out error: $msg" };
        $last_alarm = alarm $secs;

        my $start_time = gettimeofday();
            $code->();
        App::MadEye->context->log('debug' => "stopwatch: " . (gettimeofday() - $start_time));
    };
    if ($@) {
        my $err = $@;
        App::MadEye->context->log('error' => $err);
        warn $err;
    }
    alarm $last_alarm; # restore
}

sub get_schema_from_pod {
    my $target = shift;
    my $proto = ref $target || $target;

    my $parser = Pod::POM->new;
    my $pom = $parser->parse(Class::Inspector->resolved_filename($proto));
    if (my $schema_node = first { $_->title eq 'SCHEMA' } $pom->head1) {
        my $schema_content = $schema_node->content;
        $schema_content =~ s/^    //gm;
        my $schema = YAML::Load($schema_content);
        return $schema;
    } else {
        return; # 404 schema not found.
    }
}

sub snmp_session {
    my ($agent, $host, $callback, ) = @_;

    my $community = $agent->config->{config}->{community} or die "missing community";
    my $port      = $agent->config->{config}->{port}    || 161;
    my $timeout   = $agent->config->{config}->{timeout} || 10;

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
