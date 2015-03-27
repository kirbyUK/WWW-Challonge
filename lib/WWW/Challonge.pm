package WWW::Challonge;
use WWW::Challonge::Tournament;
use REST::Client;
use JSON qw/from_json/;

use 5.006;
use strict;
use warnings;

=head1 NAME

WWW::Challonge - Perl wrapper for the Challonge API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Access the Challonge API within Perl. Contains all the functions within the API,
as documented L<here|http:://api.challonge.com/v1>.

Perhaps a little code snippet.

    use WWW::Challonge;

    my $c = WWW::Challonge->new($api_key)
    ...

=head1 SUBROUTINES/METHODS

=head2 new

Creates a new C<WWW::Challonge> object. Takes in an API key, which is required:

    my $c = WWW::Challonge->new($api_key);

=cut

sub new
{
	# Get the API key:
	my $class = shift;
	my $key = shift;

	# Create a REST client to interface Challonge:
	my $client = REST::Client->new();
	$client->setHost("https://api.challonge.com/v1");

	# Try to get some content and check the response code:
	$client->GET("/tournaments.json?api_key=$key");

	# Check to see if the API key is valid:
	if($client->responseCode() eq '401')
	{
		# If it isn't, warn the user and exit:
		print STDERR "Error: Challonge API key is invalid.\n";
		return undef;
	}

	# Otherwise, keep the key and the client in an object and return:
	my $c = { key => $key, client => $client };
	bless $c, $class;
}

=head2 index

Returns an arrayref of all C<WWW::Challonge::Tournament> objects owned by the
user authenticated with in the 'new' request (the logged in user, so to speak).
Takes a number of optional arguments: 

=over 4

=item state

Get tournaments based on their progress:

=over 4

=item all

Gets all tournaments regardless of state.

=item pending

Gets all tournaments that have yet to start.

=item in_progress

Gets all tournaments that have started but have not finished.

=item ended

Gets all tournaments that have finished.

=back

=item type

Gets all tournaments of the given type:

=over 4

=item single_elimination

=item double_elimination

=item round_robin

=item swiss

=back

=item created_after

Gets all the tournaments created after the given date. Can be given as a string
(YYYY-MM-DD) or as a C<DateTime> object.

=item created_before

Gets all the tournaments created before the given date. Can be given as a string
(YYYY-MM-DD) or as a C<DateTime> object.

=item subdomain

Gets all tournaments created under the given subdomian.

=back

	my $tournies  = $c->index();
	my $tournies2 = $c->index({
		type => "double_elimination",
		created_after => "2015-03-18",
	});

=cut

sub index
{
	my $self = shift;
	my $options = shift // {};

	# Get the key and the client:
	my $key = $self->{key};
	my $client = $self->{client};

	# The intial request URL:
	my $req = "/tournaments.json?api_key=$key";

	# Loop through the options (if any) and add them on:
	for my $option(keys %{$options})
	{
		# Validate the input:
		if($option =~ /^state$/)
		{
			if($options->{$option} !~ /^all|pending|in_progress|ended$/)
			{
				print STDERR "Error: Argument '" . $options->{option} .
					"' for option '$option' is invalid.";
			}
		}
		elsif($option =~ /^type$/)
		{
			if($options->{$option} !~ /^(single|double)_elimination|round_robin|swiss$/)
			{
				print STDERR "Error: Argument '" . $options->{option} .
					"' for option '$option' is invalid.";
			}
		}
		elsif($option =~ /^created_(before|after)$/)
		{
			if($options->{$option} !~ /^\d{4}-\d{2}-\d{2}$/)
			{
				print STDERR "Error: Argument '" . $options->{option} .
					"' for option '$option' is invalid.";
			}
		}
		elsif($option =~ /^subdomain$/)
		{
			if($options->{$option} !~ /^[a-zA-Z0-9_]*$/)
			{
				print STDERR "Error: Argument '" . $options->{option} .
					"' for option '$option' is invalid.";
			}
		}
		else
		{
			print STDERR "Error: Option '$option' is invalid.";
			return undef;
		}

		$req .= "&" . $option . "=" . $options->{$option};
	}

	# Make the request:
	$client->GET($req);

	# Make a new tournament object for every tourney returned:
	my @tournaments;
	for my $tournament(@{from_json($client->responseContent())})
	{
		push @tournaments, WWW::Challonge::Tournament->new($tournament);
	}

	# Return the array of tournaments:
	return \@tournaments;
}

=head2 show

Gets a single C<WWW::Challonge::Tournament> object by the given id or URL:

	my $tourney = $c->show("sample_tournament_1");

=cut

sub show
{
}

=head1 AUTHOR

Alex Kerr, C<< <kirby at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-challonge at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Challonge>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Challonge

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

1; # End of WWW::Challonge
