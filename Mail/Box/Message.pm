use strict;
use warnings;

package Mail::Box::Message;
our $VERSION = 2.023;  # Part of Mail::Box
use base 'Mail::Message';

use Date::Parse;
use Scalar::Util 'weaken';

sub init($)
{   my ($self, $args) = @_;
    $self->SUPER::init($args);

    $self->{MBM_deleted}    = $args->{deleted}   || 0;

    $self->{MBM_body_type}  = $args->{body_type}
        if exists $args->{body_type};

    $self->{MBM_folder}     = $args->{folder};
    weaken($self->{MBM_folder});

    return $self if $self->isDummy;

    $self;
}

sub coerce($)
{   my ($class, $message) = @_;
    return bless $message, $class
        if $message->isa(__PACKAGE__);

    my $coerced = $class->SUPER::coerce($message);
    $coerced->{MBM_deleted} = 0;
    $coerced;
}

sub folder(;$)
{   my $self = shift;
    if(@_)
    {   $self->{MBM_folder} = shift;
        weaken($self->{MBM_folder});
    }
    $self->{MBM_folder};
}

sub seqnr(;$)
{   my $self = shift;
    @_ ? $self->{MBM_seqnr} = shift : $self->{MBM_seqnr};
}

sub copyTo($)
{   my ($self, $folder) = @_;
    $folder->addMessage($self->clone);
}

sub moveTo($)
{   my ($self, $folder) = @_;
    my $added = $folder->addMessage($self->clone);
    $self->delete;
    $added;
}

sub head(;$)
{   my $self  = shift;
    return $self->SUPER::head unless @_;

    my $new   = shift;
    my $old   = $self->head;
    $self->SUPER::head($new);

    return unless defined $new || defined $old;

    my $folder = $self->folder
        or return $new;

    if(!defined $new && defined $old && !$old->isDelayed)
    {   $folder->messageId($self->messageId, undef);
        $folder->toBeUnthreaded($self);
    }
    elsif(defined $new && !$new->isDelayed)
    {   $folder->messageId($self->messageId, $self);
        $folder->toBeThreaded($self);
    }

    $new || $old;
}

sub delete() { shift->deleted(1) }

sub deleted(;$)
{   my $self = shift;
    return $self->{MBM_deleted} unless @_;

    my $delete = shift;
    return $delete if $delete==$self->{MBM_deleted};

    $self->{MBM_deleted} = ($delete ? time : 0);
}

sub shortSize(;$)
{   my $self = shift;
    my $size = shift || $self->head->guessBodySize;

      !defined $size     ? '?'
    : $size < 1_000      ? sprintf "%3d "  , $size
    : $size < 10_000     ? sprintf "%3.1fK", $size/1024
    : $size < 100_000    ? sprintf "%3.0fK", $size/1024
    : $size < 1_000_000  ? sprintf "%3.2fM", $size/(1024*1024)
    : $size < 10_000_000 ? sprintf "%3.1fM", $size/(1024*1024)
    :                      sprintf "%3.0fM", $size/(1024*1024);
}

sub shortString()
{   my $self    = shift;
    my $subject = $self->head->get('subject') || '';
    chomp $subject;

    sprintf "%4s(%2d) %-30.30s", $self->shortSize, $subject;
}

sub readBody($$;$)
{   my ($self, $parser, $head, $getbodytype) = @_;

    unless($getbodytype)
    {   my $folder   = $self->{MBM_folder};
        $getbodytype = sub {$folder->determineBodyType(@_)};
    }

    $self->SUPER::readBody($parser, $head, $getbodytype);
}

sub diskDelete() { shift }

sub forceLoad() {   # compatibility
   my $self = shift;
   $self->loadBody(@_);
   $self;
}

1;
