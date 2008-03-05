package App::MadEye::Util;
use strict;
use warnings;
use base qw/Exporter/;

our @EXPORT = qw/timeout log_stopwatch/;
use Sys::Syslog qw/:DEFAULT/;

sub timeout($$&) {    ## no critic.
    my ( $secs, $msg, $code ) = @_;
    my $last_alarm = 0;
    eval {
        local $SIG{ALRM} = sub { die "Time out error: $msg" };
        $last_alarm = alarm $secs;
        $code->();
    };
    if ($@) {
        warn $@;
    }
    alarm $last_alarm; # restore
}

sub log_stopwatch ($&) {    ## no critic.
    my ( $msg, $code ) = @_;

    my $start = time;
    $code->();
    my $end = time;

    my $time = $end - $start;

    openlog 'MadEye', 'cons', 'local6';
    syslog 'info', sprintf( $msg, $time );
    closelog;
}

1;
