use strict;
use warnings;

package Mail::Transport::Qmail;
use vars '$VERSION';
$VERSION = '2.060';
use base 'Mail::Transport::Send';

use Carp;


sub init($)
{   my ($self, $args) = @_;

    $args->{via} = 'qmail';

    $self->SUPER::init($args) or return;

    $self->{MTM_program}
      = $args->{proxy}
     || $self->findBinary('qmail-inject', '/var/qmail/bin')
     || return;

    $self;
}

#------------------------------------------


sub trySend($@)
{   my ($self, $message, %args) = @_;

    my $program = $self->{MTM_program};
    if(open(MAILER, '|-')==0)
    {   { exec $program; }
        $self->log(NOTICE => "Errors when opening pipe to $program: $!");
        exit 1;
    }
 
    $self->putContent($message, \*MAILER, undisclosed => 1);

    unless(close MAILER)
    {   $self->log(ERROR => "Errors when closing Qmail mailer $program: $!");
        $? ||= $!;
        return 0;
    }

    1;
}

#------------------------------------------

1;
