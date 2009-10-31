package Padre::Wx::Swarm::VectorScope;

use strict;
use warnings;
use Padre::Wx ();

our @ISA = qw(Wx::ScrolledWindow);

use Wx qw(wxCURSOR_PENCIL wxBLACK);
use Wx::Event qw(EVT_MOTION EVT_LEFT_DOWN EVT_LEFT_UP);

use vars qw($x_size $y_size);

( $x_size, $y_size ) = ( 200, 800 );

sub new {
  my $class = shift;
  my $this = $class->SUPER::new( @_ );
  #my $dc = Wx::wxBufferedPaintDC->new( $this );
  
  $this->SetScrollbars( 1, 1, $x_size, $y_size );
  $this->SetBackgroundColour( Wx::wxBLACK );
  $this->SetCursor( Wx::Cursor->new( Wx::wxCURSOR_PENCIL ) );

  Wx::wxEVT_MOTION( $this, \&OnMouseMove );
  Wx::wxEVT_LEFT_DOWN( $this, \&OnButton );
  Wx::wxEVT_LEFT_UP( $this, \&OnButton );

  return $this;
}

use Wx qw(:font);
use Wx qw(:colour :pen);

sub OnDraw {
  my $this = shift;
  my $dc = shift;
#  my $font = Wx::Font->new( 20, wxSCRIPT, wxSLANT, wxBOLD );

#  $dc->SetFont( $font );
  $dc->DrawRotatedText( "Draw Here", 200, 200, 35 );

  $dc->DrawEllipse( 20, 20, 50, 50 );
  $dc->DrawEllipse( 20, $y_size - 50 - 20, 50, 50 );
  $dc->DrawEllipse( $x_size - 50 - 20, 20, 50, 50 );
  $dc->DrawEllipse( $x_size - 50 - 20, $y_size - 50 - 20, 50, 50 );

  $dc->SetPen( Wx::Pen->new( wxRED, 5, 0 ) );
  # wxGTK does not like DrawLines in this context
  foreach my $i ( @{$this->{LINES}} ) {
    my $prev;

    foreach my $j ( @$i ) {
      if( $j != ${$i}[0] ) {
        $dc->DrawLine( @$prev, @$j );
#       $dc->DrawLines( $i );
      }
      $prev = $j;
    }
  }
}

sub OnMouseMove {
  my( $this, $event ) = @_;

  return unless $event->Dragging;

  my $dc = Wx::ClientDC->new( $this );
  $this->PrepareDC( $dc );
  my $pos = $event->GetLogicalPosition( $dc );
  my( $x, $y ) = ( $pos->x, $pos->y );

  push @{$this->{CURRENT_LINE}}, [ $x, $y ];
  my $elems = @{$this->{CURRENT_LINE}};

  $dc->SetPen( Wx::Pen->new( wxRED, 5, 0 ) );
  $dc->DrawLine( @{$this->{CURRENT_LINE}[$elems-2]},
                 @{$this->{CURRENT_LINE}[$elems-1]} );

}

sub OnButton {
  my( $this, $event ) = @_;

  my $dc = Wx::ClientDC->new( $this );
  $this->PrepareDC( $dc );
  my $pos = $event->GetLogicalPosition( $dc );
  my( $x, $y ) = ( $pos->x, $pos->y );

  if( $event->LeftUp ) {
    push @{$this->{CURRENT_LINE}}, [ $x, $y ];
    push @{$this->{LINES}}, $this->{CURRENT_LINE};
    $this->ReleaseMouse();
  } else {
    $this->{CURRENT_LINE} = [ [ $x, $y ] ];
    $this->CaptureMouse();
  }

  $dc->SetPen( Wx::Pen->new( wxRED, 5, 0 ) );
  $dc->DrawLine( $x, $y, $x, $y );
}
