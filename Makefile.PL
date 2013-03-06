use inc::Module::Install;
name 'App-MadEye';
all_from 'lib/App/MadEye.pm';

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

install_script 'madeye.pl';

tests('t/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t');
build_requires 'Test::More';
build_requires 'YAML';
author_tests('xt');
cpanfile;

WriteAll;

