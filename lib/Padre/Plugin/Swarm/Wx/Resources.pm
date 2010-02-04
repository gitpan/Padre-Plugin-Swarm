package Padre::Plugin::Swarm::Wx::Resources;

use 5.008;
use strict;
use warnings;
use Padre::Wx                        ();
use Padre::Wx::Directory::SearchCtrl ();
use Padre::Plugin::Swarm::Wx::Resources::TreeCtrl ();
use Padre::Logger;
use Params::Util qw( _INSTANCE ) ;

our $VERSION = '0.07';
our @ISA     = 'Wx::Panel';

use Class::XSAccessor {
	getters => {
		tree   => 'tree',
		search => 'search',
	},
	accessors => {
		mode                  => 'mode',
		project_dir           => 'project_dir',
		previous_dir          => 'previous_dir',
		project_dir_original  => 'project_dir_original',
		previous_dir_original => 'previous_dir_original',
	},
};

sub plugin { Padre::Plugin::Swarm->instance }

# Creates the Directory Left Panel with a Search field
# and the Directory Browser
sub new {
	my $class = shift;
	my $main  = shift;

	# Create the parent panel, which will contain the search and tree
	my $self = $class->SUPER::new(
		$main->directory_panel,
		-1,
		Wx::wxDefaultPosition,
		Wx::wxDefaultSize,
	);
	$self->Hide;
	$self->{tree}   = 
		Padre::Plugin::Swarm::Wx::Resources::TreeCtrl->new($self);

	# Fill the panel
	my $sizerv = Wx::BoxSizer->new(Wx::wxVERTICAL);
	my $sizerh = Wx::BoxSizer->new(Wx::wxHORIZONTAL);
	$sizerv->Add( $self->tree,   1, Wx::wxALL | Wx::wxEXPAND, 0 );
	$sizerh->Add( $sizerv,   1, Wx::wxALL | Wx::wxEXPAND, 0 );
	
	# Fits panel layout
	$self->SetSizerAndFit($sizerh);
	$sizerh->SetSizeHints($self);
	TRACE( "Resource tree Ready - ", $self->tree );
	return $self;
	
}


sub enable {
	my $self = shift;
	TRACE( "Enable" );
	my $left = $self->main->directory_panel;
	my $position = $left->GetPageCount;
	my $pos = $left->InsertPage( $position, $self, gettext_label(), 0 );
	my $icon = Padre::Plugin::Swarm->plugin_icon;
	
	$left->SetPageBitmap($position, $icon );
	$left->SetSelection($position);

	# TODO - use wx event to catch messages. 
	$self->refresh;
	Wx::Event::EVT_COMMAND(
		$self->plugin->wx,
		-1,
		$self->plugin->message_event,
		sub { $self->on_swarm_message(@_) },
	);
	

	$self->Show;
	
	return $self;
}

sub disable {
	my $self = shift;
	TRACE( "Disabled" );
	my $left = $self->main->directory_panel;
	my $pos = $left->GetPageIndex($self);
	$self->Hide;
	$left->RemovePage($pos);
	$self->Destroy;
	
}

# The parent panel
sub panel {
	$_[0]->GetParent;
}

# Returns the main object reference
sub main {
	$_[0]->GetGrandParent;
}

sub current {
	Padre::Current->new( main => $_[0]->main );
}

# Returns the window label
sub gettext_label {
	my $self = shift;
	return Wx::gettext('Swarm');
}

# Updates the gui, so each compoment can update itself
# according to the new state
sub clear {
	$_[0]->refresh;
	return;
}

sub on_swarm_message {
	my $self = shift;
	my $wx = shift;
	my $event = shift;
	my $data = $event->GetData;
	$event->Skip(1);
	my $message = Storable::thaw( $data );
	return unless _INSTANCE( $message , 'Padre::Swarm::Message' );

	my $handler = 'accept_' . $message->type;
	TRACE( $handler ) if DEBUG;
        if ( $self->can( $handler ) ) {
            eval {
                $self->$handler($message);
            };
            TRACE( $handler . ' failed with ' . $@ ) if DEBUG && $@;
            
        }
	
}

sub accept_promote {
	my ($self,$message) = @_;
	if ( $message->{resource} ) {
		$self->refresh;
	}
}

sub accept_destroy {
	my ($self,$message) = @_;
	if ( $message->{resource} ) {
		$self->refresh;
	}
}

sub accept_disco {}



# Updates the gui if needed, calling Searcher and Browser respectives
# refresh function.
# Called outside Directory.pm, on directory browser focus and item dragging
sub refresh {
	my $self     = shift;
	TRACE( "Refresh" );	
	my $current  = $self->current;
	my $document = $current->document;



	$self->tree->refresh;



	# Update the panel label
	$self->panel->refresh;

	return 1;
}

# When a project folder is changed
sub _change_project_dir {
	my $self   = shift;
	my $dialog = Wx::DirDialog->new(
		undef,
		Wx::gettext('Choose a directory'),
		$self->project_dir,
	);
	if ( $dialog->ShowModal == Wx::wxID_CANCEL ) {
		return;
	}
	$self->{projects_dirs}->{ $self->project_dir_original } = $dialog->GetPath;
	$self->refresh;
}

# What side of the application are we on
sub side {
	my $self  = shift;
	my $panel = $self->GetParent;
	if ( $panel->isa('Padre::Wx::Left') ) {
		return 'left';
	}
	if ( $panel->isa('Padre::Wx::Right') ) {
		return 'right';
	}
	die "Bad parent panel";
}

# Moves the panel to the other side
sub move {
	my $self   = shift;
	my $config = $self->main->config;
	my $side   = $config->main_directory_panel;
	if ( $side eq 'left' ) {
		$config->apply( main_directory_panel => 'right' );
	} elsif ( $side eq 'right' ) {
		$config->apply( main_directory_panel => 'left' );
	} else {
		die "Bad main_directory_panel setting '$side'";
	}
}

1;

# Copyright 2008-2010 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.