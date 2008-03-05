#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use File::Spec::Functions;
use lib catfile($FindBin::Bin, 'lib');
use App::MadEye;

# TODO: -c foo.yaml
App::MadEye->new({config => 'config.yaml'})->run;

