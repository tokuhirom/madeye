package App::MadEye::Plugin::Notify::Nakanobu;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use JSON::RPC::Common::Marshal::HTTP;
use JSON::RPC::Common::Procedure::Call;
use YAML ();
use LWP::UserAgent;
use Text::Truncate qw/truncstr/;

sub notify :Hook {
    my ($self, $context, $args) = @_;

    my $conf = $self->{config}->{config};
    my $entry_url = $conf->{entry_url} or die "missing entry_url";
    my $channel = $conf->{channel} or die "missing channel";
    my $method = $conf->{method} || 'notice';
    my $timeout = $conf->{timeout} || 10;
    my $cutoff_length = $conf->{cutoff_length} || 300;

    my $text = _format($args, $cutoff_length);

    my $res = _request(
        $method,
        {
            channel => $channel,
            text    => $text,
        },
        URI->new($entry_url),
        $timeout,
    );

    if ($res->has_error) {
        warn YAML::Dump($res);
    }
}

sub _request {
    my ($method, $params, $entry_url, $timeout) = @_;

    my $marshal = JSON::RPC::Common::Marshal::HTTP->new();
    my $call = JSON::RPC::Common::Procedure::Call->new(
        method  => $method,
        params  => $params,
    );
    my $request = $marshal->call_to_get_request( $call, uri => $entry_url );

    my $ua = LWP::UserAgent->new(timeout => $timeout);
    my $response = $ua->request( $request );

    return $marshal->response_to_result( $response );
}

sub _format {
    my ($args, $cutoff_length) = @_;

    my $text = '';
    while (my ($module, $targets) = each %$args) {
        $module = _moniker($module);
        $text .= "= $module\n" .  truncstr(_format_target($targets), $cutoff_length) . "\n";
    }
    $text;
}

sub _format_target {
    my $targets = shift;

    my $text = '';
    for my $target (@$targets) {
        $text .= "- $target->{target}\n";
        $text .= "$target->{message}\n";
    }
    $text;
}

sub _moniker {
    my $module = shift;
    $module =~ s/.+:://;
    $module;
}

1;
