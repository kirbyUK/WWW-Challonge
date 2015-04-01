package WWW::Challonge::Tournament;

use 5.006;
use strict;
use warnings;

sub __is_kill;

=head1 NAME

WWW::Challonge::Tournament - A class representing a single Challonge tournament.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SUBROUTINES/METHODS

=head2 new

Takes a hashref representing the tournament, the API key and the REST client
and turns it into an object. This is mostly used by the module itself, to
create a new tournament see L<WWW::Challonge/create>.

	my $t = WWW::Challonge::Tournament->new($tournament, $key, $client);

=cut

sub new
{
	my $class = shift;
	my $tournament = shift;
	my $key = shift;
	my $client = shift;

	my $t =
	{
		alive => 1,
		client => $client,
		tournament => $tournament->{tournament},
		key => $key,
	};
	bless $t, $class;
}

=head2 destroy

Deletes the tournament from the user's account. There is no undo, so use with
care!

	$t->destroy;

	# $t still contains the tournament, but any future operations will fail:
	$t->update({ name => "sample_tournament_2" }); # ERROR!

=cut

sub destroy
{
	my $self = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament URL:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Make the DELETE call:
	$client->DELETE("/tournaments/$url.json?api_key=$key");

	# Set the tournament to dead to prevent further operations:
	$self->{alive} = 0;
}

=head2 __is_kill

Returns an error explaining that the current tournament has been destroyed and
returns undef, used so a function doesn't attempt to operate on a tournament
that has been successfully destroyed.

=cut

sub __is_kill
{
	print STDERR "Error: Tournament has been destroyed\n";
	return undef;
}

=head1 AUTHOR

Alex Kerr, C<< <kirby at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-challonge at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Challonge::Tournament>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Challonge::Tournament

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Challonge::Tournament>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Challonge::Tournament>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Challonge::Tournament>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Challonge::Tournament/>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Challonge>

=item L<WWW::Challonge::Participant>

=item L<WWW::Challonge::Match>

=back

=head1 ACKNOWLEDGEMENTS

Everyone on the L<Challonge|http://challonge.com> team for making such a great
service.

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Alex Kerr.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of WWW::Challonge::Tournament
