use strict;
use warnings;

package Mail::Message::Field::AddrGroup;
use vars '$VERSION';
$VERSION = '2.045';
use base 'User::Identity::Collection::Emails';


use overload '""' => 'string';

#------------------------------------------


sub string()
{   my $self = shift;
    my $name = $self->name;
    my @addr = map {$_->string} $self->addresses;

    local $" = ', ';

      length $name  ? "$name: @addr;"
    : @addr         ? "@addr"
    :                 '';
}

#------------------------------------------


sub coerce($@)
{  my ($class, $addr, %args) = @_;

   return () unless defined $addr;

   if(ref $addr)
   {  return $addr if $addr->isa($class);

      return bless $addr, $class
          if $addr->isa('User::Identity::Collection::Emails');
   }

   $class->log(ERROR => "Cannot coerce a ".(ref($addr)|'string').
                        " into a $class");
   ();
}


#------------------------------------------


sub addAddress(@)
{   my $self  = shift;

    my $addr
     = @_ > 1    ? Mail::Message::Field::Address->new(@_)
     : !$_[0]    ? return ()
     :             Mail::Message::Field::Address->coerce(shift);

    $self->addRole($addr);
    $addr;
}

#------------------------------------------


# roles are stored in a hash, so produce
sub addresses() { shift->roles }

#------------------------------------------


1;