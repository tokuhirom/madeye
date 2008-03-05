package App::MadEye;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use Class::Component;
use Params::Validate;
__PACKAGE__->load_components(qw/Plaggerize Autocall::InjectMethod/);
__PACKAGE__->load_plugins(qw/+App::MadEye::Plugin::Worker/);

sub run {
    my $self = shift;
    use Carp::Always;
    $self->log(debug => 'run');

    $self->run_hook('check');

    $self->run_workers();
    $self->kill_workers();
    $self->wait_workers();

    $self->log(debug => 'finished');
}

1;
__END__

=encoding utf8

=head1 NAME

App::MadEye -

=head1 SYNOPSIS

  use App::MadEye;

=head1 DESCRIPTION

App::MadEye is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
