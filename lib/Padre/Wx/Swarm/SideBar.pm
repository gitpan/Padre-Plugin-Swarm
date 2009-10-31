package Padre::Wx::Swarm::SideBar;

use 5.008;
use strict;
use warnings;
use Params::Util qw{ _STRING };
use Padre::Wx      ();
use Padre::Current ();
#use Padre::Wx::Swarm::VectorScope;
require Wx::DemoModules::wxPrinting;

our $VERSION = '0.36';
our @ISA     = 'Wx::Panel';

#####################################################################
# Constructor

sub new {
	my $class = shift;
	my $main  = shift;

	# Create the underlying object
	my $self = $class->SUPER::new(
		$main->right,
		-1,
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
		Wx::wxLC_REPORT 
	);

	my $sizer = Wx::BoxSizer->new( Wx::wxVERTICAL );
	#my $scope = Padre::Wx::Swarm::VectorScope->new( $self , -1);
	my $scope = Wx::DemoModules::wxPrinting::Canvas->new( $self, -1 );
	$sizer->Add( $scope, 1 , Wx::wxGROW );
	$self->SetSizer( $sizer );
	$self->SetAutoLayout(1);
	$self->Show;

	return $self;
}

sub right {
	$_[0]->GetParent;
}

sub main {
	$_[0]->GetGrandParent;
}

sub gettext_label {
	Wx::gettext('Swarm');
}



1;

# Copyright 2008-2009 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.
