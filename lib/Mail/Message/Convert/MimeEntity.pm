
use strict;
use warnings;

package Mail::Message::Convert::MimeEntity;
use vars '$VERSION';
$VERSION = '2.051';
use base 'Mail::Message::Convert';

use MIME::Entity;
use MIME::Parser;
use Mail::Message;


sub export($$;$)
{   my ($self, $message, $parser) = @_;
    return () unless defined $message;

    $self->log(ERROR =>
       "Export message must be a Mail::Message, but is a ".ref($message)."."),
           return
              unless $message->isa('Mail::Message');

    $parser ||= MIME::Parser->new;
    $parser->parse($message->file);
}

#------------------------------------------


sub from($)
{   my ($self, $mime_ent) = @_;
    return () unless defined $mime_ent;

    $self->log(ERROR =>
       'Converting from MIME::Entity but got a '.ref($mime_ent).'.'), return
            unless $mime_ent->isa('MIME::Entity');

    Mail::Message->read($mime_ent->as_string);
}

#------------------------------------------

1;
