use inc::Module::Install;
name 'App-MadEye';
all_from 'lib/App/MadEye.pm';

requires 'Class::Component' => '0.17';
requires 'LWP::UserAgent';
requires 'Params::Validate' => 0.91;
requires 'YAML';
requires 'IO::Socket::INET';
requires 'Socket';
requires 'IO::Select';
requires 'IO::Socket::SSL';
requires 'Net::SSH';
requires 'IPC::Open3';
requires 'Kwalify';
requires 'Pod::POM';
requires 'List::Util';
requires 'Log::Dispatch';
requires 'Net::SNMP';

features(
    'Agent::DBI' => [
        recommends('DBI'),
    ],
    'Agent::MogileFSTracker' => [
        -default => 0,
        recommends('MogileFS::Admin'),
    ],
    'Agent::DNS' => [
        -default => 0,
        recommends('Net::DNS'),
    ],
    'Agent::SMTPTLS' => [
        recommends('Net::SMTP::TLS')
    ],
    'Agent::Ping' => [
        recommends('Net::Ping')
    ],
    'Agent::SMTP' => [
        recommends('Net::SMTP')
    ],
    'Worker::Gearman' => [
        recommends('Gearman::Client'),
        recommends('Gearman::Worker'),
        recommends('Storable'),
    ],
    'Rule::Retry' => [
        recommends('Cache::FileCache'),
    ],
);

tests('t/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t');
build_requires 'Test::More';
build_requires 'YAML';
author_tests('xt');
use_test_base;
auto_include;
WriteAll;

