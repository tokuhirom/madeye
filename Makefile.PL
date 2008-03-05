use inc::Module::Install;
name 'App-MadEye';
all_from 'lib/App/MadEye.pm';

requires 'Gearman::Client';
requires 'Gearman::Worker';
requires 'Class::Component';
requires 'LWP::UserAgent';

build_requires 'Test::More';
build_requires 'YAML';
use_test_base;
auto_include;
WriteAll;
