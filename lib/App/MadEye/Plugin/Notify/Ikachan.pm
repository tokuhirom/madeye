package App::MadEye::Plugin::Notify::Ikachan;
use strict;
use warnings;
use utf8;
use base qw/App::MadEye::Plugin::Base/;

use Furl;

sub notify : Hook {
    my ($self, $context, $args) = @_;

    my $conf = $self->{config}->{config};
    my $url   = $conf->{url} or die "missing url";
    $url =~ s!/$!!g;

    my $channel   = $conf->{channel} or die "missing channel";

    while (my ($plugin, $results) = each %$args) {
        $plugin =~ s/.+::Agent:://;
        my $msg = "$plugin: ";
        for my $result (@$results) {
            $msg .= "($result->{target}): $result->{message} ";
        }

        my $ua = Furl->new(
            timeout => 5,
            agent => "MadEye/$App::MadEye::VERSION"
        );
        my $res = $ua->post("$url/notice", [], [
            channel => $channel,
            message => $msg,
        ]);
        $res->is_success or die $res->status_line;
    }
}

1;

