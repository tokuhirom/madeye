package App::MadEye::Util;
use strict;
use warnings;
use base qw/Exporter/;

our @EXPORT = qw/timeout log_stopwatch get_schema_from_pod/;

use Sys::Syslog qw/:DEFAULT/;
use Pod::POM ();
use List::Util qw/first/;
use YAML ();

sub timeout($$&) {    ## no critic.
    my ( $secs, $msg, $code ) = @_;
    App::MadEye->context->log(debug => "run timer: '$msg', $secs");;
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

1;
