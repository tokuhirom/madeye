use inc::Module::Install;
name 'App-MadEye';
all_from 'lib/App/MadEye.pm';

requires 'Class::Component';
requires 'LWP::UserAgent';
requires 'Params::Validate';
requires 'Cache::Memcached';
requires 'YAML';
requires 'IO::Socket::INET';
requires 'Socket';
requires 'IO::Select';
requires 'IO::Socket::SSL';
requires 'Net::SSH';
requires 'IPC::Open3';

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

build_requires 'Test::More';
build_requires 'YAML';
use_test_base;
auto_include;
WriteAll;

