use strict;
use warnings;
use Test::More tests => 1;
use App::MadEye;

my $count = 0;
{
    package Notify;
    sub bar { $count++ }
    sub config { +{ } }
}

{
    package Agent;
    sub config { +{ } }
}

my $c = App::MadEye->new({config => { }});

for (1..4) {
    $c->register_hook('notify' => { plugin => 'Notify', method => 'bar'});
}
for (1..6) {
    $c->add_result(
        plugin  => 'Agent',
        target  => 'Fuga',
        message => 'Moge',
    );
}
$c->run();

is $count, 4;

