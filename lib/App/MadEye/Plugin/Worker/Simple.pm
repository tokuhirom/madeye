package App::MadEye::Plugin::Worker::Simple;
use strict;
use warnings;
use base qw/Class::Component::Plugin/;
use App::MadEye::Util;
use Params::Validate;

our $TIMEOUT = 60;  # TODO: configurable
our $EXPTIME = 180; # TODO: configurable

# nop.
sub run_workers  : Method { }
sub wait_jobs    : Method { }
sub kill_workers : Method { }
sub wait_workers : Method { }

sub register_job :Method {
    my ($self, $context, $args) = @_;

    $context->log( debug => "watching $args->{target} by $args->{plugin}" );

    timeout $TIMEOUT, "watching $args->{target} $args->{plugin}", sub {
        if ( my $message = $args->{plugin}->is_dead( $args->{target} ) ) {
            # TODO: このあたりのルールもちゃんとつくる
            if (
                $self->should_notify_p(
                    target  => $args->{target},
                    context => $context,
                )
                )
            {
                $context->add_result(
                    plugin  => $args->{plugin},
                    target  => $args->{target},
                    message => $message,
                );
            }
        }
    };

    $context->log( debug => "finished $args->{target} by $args->{plugin}" );
}

# これはここにあるべきか？ちげーだろ。
sub should_notify_p {
    my $self = shift;
    validate(
        @_ => {
            target  => 1,
            context => 1,
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

1;

