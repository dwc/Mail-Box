package Mail::Box::Search::SpamAssassin;
our $VERSION = 2.029;  # Part of Mail::Box
use base 'Mail::Box::Search';

use strict;
use warnings;

use Mail::SpamAssassin;
use Mail::Message::Wrapper::SpamAssassin;

sub init($)
{   my ($self, $args) = @_;

    $args->{in}  ||= 'MESSAGE';
    $args->{label} = 'spam' unless exists $args->{label};

    $self->SUPER::init($args);

    $self->{MBSS_rewrite_mail}
       = defined $args->{rewrite_mail} ? $args->{rewrite_mail} : 1;

    $self->{MBSS_sa}
       = defined $args->{spamassassin} ? $args->{spamassassin}
       : Mail::SpamAssassin->new($args->{sa_options} || {});

    $self;
}

sub assassinator() { shift->{MBSS_sa} }

sub searchPart($)
{   my ($self, $message) = @_;

    my @details = (message => $message);

    my $sa      = Mail::Message::Wrapper::SpamAssassin->new($message);
    my $status  = $self->assassinator->check($sa);

    my $is_spam = $status->is_spam;
    $status->rewrite_mail if $self->{MBSS_rewrite_mail};

    if($is_spam)
    {   my $deliver = $self->{MBS_deliver};
        $deliver->( {@details, status => $status} ) if defined $deliver;
    }

    $is_spam;
}

sub inHead(@) {shift->notImplemented}

sub inBody(@) {shift->notImplemented}

1;