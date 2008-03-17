package App::MadEye::Plugin::Agent::HTTP;
use strict;
use warnings;
use LWP::UserAgent;
use App::MadEye::Plugin::Agent::Base;

our $TIMEOUT = 15;

sub is_dead {
    my ($self, $url) = @_;

    my $ua = LWP::UserAgent->new(
        timeout => $TIMEOUT,
        agent   => $self->config->{config}->{user_agent} || "App::MadEye($App::MadEye::VERSION)",
    );
    my $res = $ua->get($url);

    if ($res->code == 200) {
        return 0;
    } else {
        return join( "\n", $res->code, $res->message, $res->content );
    }
}

1;
__END__

=head1 NAME

App::MadEye::Plugin::Agent::HTTP - check http.

=head1 SCHEMA

    type: map
    mapping:
        target:
            type: seq
            required: yes
            sequence:
                - type: str
        timeout:
            required: yes
            type: int
        user_agent:
            required: no
            type: str

=head1 AUTHOR

Tokuhiro Matsuno

=head1 SEE ALSO

L<App::MadEye>, L<Gearman::Client>, L<Gearman::Worker>

