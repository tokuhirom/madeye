package App::MadEye::Plugin::Base;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use Kwalify ();
use Pod::POM ();
use List::Util qw/first/;
use YAML ();

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    my $parser = Pod::POM->new;
    my $pom = $parser->parse(Class::Inspector->resolved_filename($class));
    if (my $schema_node = first { $_->title eq 'SCHEMA' } $pom->head1) {
        my $schema_content = $schema_node->content;
        $schema_content =~ s/^    //gm;
        my $schema = YAML::Load($schema_content);

        Kwalify::validate($schema, $self->config->{config});
    }

    $self;
}

1;

