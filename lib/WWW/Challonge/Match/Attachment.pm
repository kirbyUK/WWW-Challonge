package WWW::Challonge::Match::Attachment;

use 5.006;
use strict;
use warnings;
use JSON qw/to_json from_json/;

sub __args_are_valid;

=head1 NAME

WWW::Challonge::Match::Attachment - A class representing a single match
attachement within a Challonge tournament.

=head1 VERSION

Version 0.11

=cut

our $VERSION = '0.11';

=head1 SUBROUTINES/METHODS

=head2 new

Takes a hashref representing the match attachment, the API key and the REST
client and turns it into an object. This is mostly used by the module itself.
To see how to create a match attachment, see L<WWW::Challonge::Match/create>.

	my $ma = WWW::Challonge::Match::Attachment->new($match, $key, $client);

=cut

sub new
{
	my $class = shift;
	my $attachment = shift;
	my $key = shift;
	my $client = shift;

	my $ma =
	{
		client => $client,
		attachment => $attachment->{match_attachment},
		key => $key,
	};
	bless $ma, $class;
}

=head2 update

Updates the attributes of the match attachment. Takes the same arguments as
L<WWW::Challonge::Match/create>.

	$ma->update({ url => "www.example.com/example2.png" });

=cut

sub update
{
	my $self = shift;
	my $args = shift;

	# Get the key, REST client and match id:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{match}->{tournament_id};
	my $id = $self->{match}->{id};
}

=head2 attributes

Returns a hashref of all the attributes of the match attachment. Contains the
following fields.

=over 4

=item asset_content_type

=item asset_file_name

=item asset_file_size

=item asset_url

=item created_at

=item description

=item id

=item match_id

=item original_file_name

=item updated_at

=item url

=item user_id

=back

	my $attr = $m->attributes;
	print $attr->{}, "\n";

=cut

sub attributes
{
	my $self = shift;

	# Get the key, REST client, tournament url and id:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{match}->{tournament_id};
	my $id = $self->{match}->{id};
}

=head2 __args_are_valid

Checks if the passed arguments and values are valid for updating a match
attachment.

=cut

sub __args_are_valid
{
	my $args = shift;
}

=head1 AUTHOR

Alex Kerr, C<< <kirby at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-challonge at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Challonge::Match>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Challonge::Match::Attachment

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Challonge>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Challonge>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Challonge>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Challonge/>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Challonge>

=item L<WWW::Challonge::Tournament>

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

1; # End of WWW::Challonge::Match::Attachment
