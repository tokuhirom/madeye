package App::MadEye::Plugin::Worker;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use Gearman::Worker;
use Gearman::Client;
use App::MadEye::Util;
use Params::Validate;
use English;
use App::MadEye::Util;
use POSIX ":sys_wait_h";

our $TIMEOUT = 60;  # TODO: configurable
our $EXPTIME = 180; # TODO: configurable

sub run_workers : Method {
    my ($self, $context) = @_;

    my $parent_pid = $PID;
    my @child_pids;
    for my $i ( 0 .. $self->config->{config}->{fork_num}- 1 ) {
        my $pid = fork();
        if ($pid) {
            # parent process
            push @child_pids, $pid;
        } elsif ( defined $pid ) {
            # child process
            $self->run_worker($parent_pid);
        } else {
            die "Cannot fork: $!";
        }
    }
    $context->{child_pids} = \@child_pids;
}

sub kill_workers :Method {
    my ( $self, $context ) = @_;

    my $taskset = $self->gearman_client->new_task_set;
    for my $child_pid (@{ $context->{child_pids} }) {
        $taskset->add_task( "exit$child_pid", undef );
    }
}

sub gearman_client {
    my $self = shift;

    my $client = Gearman::Client->new;
    $client->job_servers( @{ $self->config->{config}->{gearman_servers} } );
    $client->prefix($PID);
    $client;
}

sub wait_workers : Method {
    my ( $self, $context ) = @_;

    timeout $TIMEOUT, 'wait_children', sub {
        my $dead_children = 0;
        while ( $dead_children < $self->config->{config}->{fork_num} ) {
            my $kid = waitpid( -1, &WNOHANG );
            if ($kid) {
                $dead_children++;
            }
        }
    };
}

sub run_worker {
    my ($self, $parent_pid) = @_;

    my $worker = Gearman::Worker->new;
    $worker->job_servers( @{ $self->config->{config}->{gearman_servers} } );
    $worker->prefix($parent_pid);
    $worker->register_function(
        "watch",
        sub {
            my $args = thaw( $_[0]->arg );

            my $result = \undef;
            timeout $TIMEOUT, "watching $args->{host} $args->{module}", sub {
                my $agent = load_agent( $args->{module} );
                unless ( $agent->is_alive( $args->{host}, $args->{args} ) ) {
                    if (
                        $self->should_notify_p(
                            host => $args->{host},
                            opt  => $args
                        )
                      )
                    {
                        $result = +{ msg => $agent->message, };
                    }
                }
            };
            return freeze($result);
        }
    );
    $worker->register_function(
        "exit$$",
        sub {
            exit;
        }
    );
    $worker->work while 1;
}

=head1


# これはここにあるべきか？ちげーだろ。
sub should_notify_p {
    my $self = shift;
    validate(
        @_ => {
            host => 1,
            opt  => 1,
        }
    );
    my %args = @_;
    my $host = $args{host};

    # ある時間帯だけスルーさせるルール
    if ( my $param = $args{opt}->{args}->{neglect_hours}->{$host} ) {
        my $now = DateTime->now;
        my %ymd = map { ( $_ => $now->$_ ) } qw(year month day);
        if (
            $now->between(
                map { DateTime->new( %ymd, %{ $param->{$_} } ) }
                  qw(start_time end_time)
            )
          )
        {
            return 0;
        }
    }

   # 再起動のタイミングとかで応答しないこともあるので、
   # 一回ぐらい落ちてても気にしないというルール
    if ( $args{opt}->{args}->{should_retry} ) {
        my $cache_key = "$host-is-dead";

        my $recent_dead_fg = $self->cache->get($cache_key) ? 1 : 0;

        # 今回死んだことをここに記す。
        $self->cache->set( $cache_key => 1, $EXPTIME );

        return $recent_dead_fg;
    }

    return 1;    # 死んでるんだからおしらせしとけや
}

=cut

1;

