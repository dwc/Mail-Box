
use strict;
use warnings;

package Mail::Message::TransferEnc::Binary;
use base 'Mail::Message::TransferEnc';

our $VERSION = 2.017;

=head1 NAME

Mail::Message::TransferEnc::Binary - encode/decode binary message bodies

=head1 CLASS HIERARCHY

 Mail::Message::TransferEnc::Binary
 is a Mail::Message::TransferEnc
 is a Mail::Reporter

=head1 SYNOPSIS

 my Mail::Message $msg = ...;
 my $decoded = $msg->decoded;
 my $encoded = $msg->encode(transfer => 'binary');

=head1 DESCRIPTION

Encode or decode message bodies for binary transfer encoding.  This is
totally no encoding.

=head1 METHOD INDEX

Methods prefixed with an abbreviation are described in
L<Mail::Reporter> (MR), L<Mail::Message::TransferEnc> (MMT).

The general methods for C<Mail::Message::TransferEnc::Binary> objects:

  MMT check BODY [, OPTIONS]           MMT name
  MMT create TYPE, OPTIONS                 new OPTIONS
  MMT decode BODY [, OPTIONS]           MR report [LEVEL]
  MMT encode BODY [, OPTIONS]           MR reportAll [LEVEL]
   MR errors                            MR trace [LEVEL]
   MR log [LEVEL [,STRINGS]]            MR warnings

The extra methods for extension writers:

   MR AUTOLOAD                          MR logPriority LEVEL
   MR DESTROY                           MR logSettings
  MMT addTransferEncoder TYPE, CLASS    MR notImplemented
   MR inGlobalDestruction

=head1 METHODS

=over 4

=cut

#------------------------------------------

=item new OPTIONS

 OPTION            DESCRIBED IN          DEFAULT
 log               Mail::Reporter        'WARNINGS'
 trace             Mail::Reporter        'WARNINGS'

=cut

#------------------------------------------

sub name() { 'binary' }

#------------------------------------------

sub check($@)
{   my ($self, $body, %args) = @_;
    $body;
}

#------------------------------------------

sub decode($@)
{   my ($self, $body, %args) = @_;
    $body->transferEncoding('none');
    $body;
}

#------------------------------------------

sub encode($@)
{   my ($self, $body, %args) = @_;

    my @lines;

    my $changes = 0;
    foreach ($self->lines)
    {   $changes++ if s/[\000\013]//g;
        push @lines, $_;
    }

    unless($changes)
    {   $body->transferEncoding('none');
        return $body;
    }

    my $bodytype = $args{result_type} || ref($self->load);

    $bodytype->new
     ( based_on          => $self
     , transfer_encoding => 'none'
     , data              => \@lines
     );
}

#------------------------------------------

=back

=head1 METHODS for extension writers

=over 4

=cut

#------------------------------------------

=back

=head1 SEE ALSO

L<Mail::Box-Overview>

For support and additional documentation, see http://perl.overmeer.net/mailbox/

=head1 AUTHOR

Mark Overmeer (F<mailbox@overmeer.net>).
All rights reserved.  This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 VERSION

This code is beta, version 2.017.

Copyright (c) 2001-2002 Mark Overmeer. All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
