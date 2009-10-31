package Padre::Wx::Swarm::Event;

use strict;
use warnings;

use Padre::Wx ();

our $VERSION = "0.38";

=pod 

announce( service , node, etc )

discover(['interesting'])



advertise ( services )

subscribe

unsubscribe

=cut


{
my $e : shared = Wx::NewEventType();
sub announce { 
  $e;
}

}

{
 my $e : shared = Wx::NewEventType();
sub discover { $e }
}

{
 my $e : shared = Wx::NewEventType();
sub advertise { $e }
}

{
 my $e : shared = Wx::NewEventType();
sub subscribe { $e }
}

{
 my $e : shared = Wx::NewEventType();
sub unsubscribe { $e }
}


sub register_event {
  die "Not implemented";
}


### Events



1;
