package App::MadEye;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use Class::Component;
use Params::Validate;
__PACKAGE__->load_components(qw/Plaggerize Autocall::InjectMethod/);

sub run {
    my $self = shift;
    $self->log(debug => 'run');

    unless ($self->can('run_workers')) {
        $self->log(debug => 'use Worker::Simple');
        $self->load_plugins(qw/Worker::Simple/);
    }

    $self->run_hook('check');

    $self->run_hook('before_run_jobs');

        $self->run_hook('run_jobs');

    $self->run_hook('after_run_jobs');

    $self->run_hook('notify' => $self->{results});

    $self->log(debug => 'finished');
}

sub add_result {
    my $self = shift;
    validate(
        @_ => +{
            plugin  => 1,
            target  => 1,
            message => 1,
        }
    );
    my $args = {@_};

    push @{$self->{results}->{ref $args->{plugin}}}, +{
        target  => $args->{target},
        message => $args->{message},
    }; 
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
