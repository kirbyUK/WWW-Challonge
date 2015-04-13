package WWW::Challonge::Match;

use 5.006;
use strict;
use warnings;
use JSON qw/to_json from_json/;

sub __args_are_valid;

=head1 NAME

WWW::Challonge::Match - A class representing a single match within
a Challonge tournament.

=head1 VERSION

Version 0.11

=cut

our $VERSION = '0.11';

=head1 SUBROUTINES/METHODS

=head2 new

Takes a hashref representing the match, the API key and the REST client and
turns it into an object. This is mostly used by the module itself.

	my $p = WWW::Challonge::Match->new($match, $key, $client);

=cut

sub new
{
	my $class = shift;
	my $match = shift;
	my $key = shift;
	my $client = shift;

	my $m =
	{
		client => $client,
		match => $match->{match},
		key => $key,
	};
	bless $m, $class;
}

=head2 update

Updates the match with the results. Requires an arrayref of comma-seperated
values and optional arguments for votes. The 'winner_id' is not required as the
module calculates it. Returns the updated C<WWW::Challonge::Match> object:

=over 4

=item scores_csv

Required. An arrayref containing the match results with the following format -
"x-y", where x and y are both integers, x being player 1's score and y being
player 2's.

=item player1_votes

Integer. Overwrites the number of votes for player 1.

=item player2_votes

Integer. Overwrites the number of votes for player 2.

=back

	# If votes are not given, the argument can simply be an arrayref:
	$m->update(["1-3", "3-2", "3-0"]);

	# Otherwise, a hashref is required:
	$m->update({
		scores_csv => ["1-3", "3-2", "3-0"],
		player1_votes => 2,
		player2_votes => 1,
	});

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

	my $params = { api_key => $key, match => { } };

	# Check what kind of arguments we are dealing with:
	if((ref $args eq "ARRAY") || (ref $args eq "HASH"))
	{
		# Check we have the mandatory scores:
		if((ref $args eq "HASH") && ((! defined $args->{scores_csv}) ||
			(ref $args->{scores_csv} ne "ARRAY")))
		{
			print STDERR "Error: Required argument 'scores_csv' as an array ",
				"reference of scores.\n";
			return undef;
		}

		# Check the arguments are valid:
		return undef unless(__args_are_valid($args));

		# Once everything is good, work out the winner based on the results:
		my $results = $args;
		if(ref $args eq "HASH") { $results = $args->{scores_csv}; }
		my %results = ( p1 => 0, p2 => 0 );
		for my $result(@{$results})
		{
			# Increment the score of whoever has the highest result:
			my ($p1, $p2) = split '-', $result;
			($p1 > $p2) ? $results{p1}++ : $results{p2}++;
		}

		# Save the id of whichever player got the most wins:
		if($results{p1} > $results{p2})
		{
			$params->{match}->{winner_id} = $self->{match}->{player1_id};
		}
		elsif($results{p1} < $results{p2})
		{
			$params->{match}->{winner_id} = $self->{match}->{player2_id};
		}
		else
		{
			$params->{match}->{winner_id} = "tie";
		}

		# Save the scores as a comma-seperated list:
		$params->{match}->{scores_csv} = join ",", @{$results};

		# Go through and add the prediction arguments if they exist:
		if(ref $args eq "HASH")
		{
			for my $key(keys %{$args})
			{
				next unless($key =~ /^player[12]_votes$/);
				$params->{match}->{$key} = $args->{$key};
			}
		}

		# Make the PUT call:
		$client->PUT("/tournaments/$url/matches/$id.json", to_json($params),
			{ "Content-Type" => 'application/json' });

		# Check if it was successful:
		if($client->responseCode > 300)
		{
			my $errors = from_json($client->responseContent)->{errors};
			for my $error(@{$errors})
			{
				print STDERR "Error: $error\n";
			}
			return undef;
		}

		# If so, update the store of the match:
		$self->{match} = from_json($client->responseContent)->{match};
	}
	else
	{
		# Otherwise, give an error and exit:
		print STDERR "Error: Expected an arrayref or hashref.\n";
		return undef;
	}
}

=head2 attributes

Returns a hashref of all the attributes of the match. Contains the following
fields.

=over 4

=item attachment_count

=item created_at

=item group_id

=item has_attachment

=item id

=item identifier

=item location

=item loser_id

=item player1_id

=item player1_is_prereq_match_loser

=item player1_prereq_match_id

=item player1_votes

=item player2_id

=item player2_is_prereq_match_loser

=item player2_prereq_match_id

=item player2_votes

=item prerequisite_match_ids_csv

=item round

=item scheduled_time

=item scores_csv

=item started_at

=item state

=item tournament_id

=item underway_at

=item updated_at

=item winner_id

=back

	my $attr = $m->attributes;
	print $attr->{identifier}, "\n";

=cut

sub attributes
{
	my $self = shift;

	# Get the key, REST client, tournament url and id:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{match}->{tournament_id};
	my $id = $self->{match}->{id};

	# Get the most recent version:
	$client->GET("/tournaments/$url/matches/$id.json?api_key=$key");

	# Check if it was successful:
	if($client->responseCode > 300)
	{
		my $errors = from_json($client->responseContent)->{errors};
		for my $error(@{$errors})
		{
			print STDERR "Error: $error\n";
		}
		return undef;
	}

	# If so, save it and then return it:
	$self->{match} = from_json($client->responseContent)->{match};
	return $self->{match};
}

=head2 __args_are_valid

Checks if the passed arguments and values are valid for updating a match.

=cut

sub __args_are_valid
{
	my $args = shift;
	my $results = $args;
	if(ref $args eq "HASH") { $results = $args->{scores_csv}; }

	# Check the arrayref contains the correct values:
	for my $result(@{$results})
	{
		if($result !~ /^\d*-\d*$/)
		{
			print STDERR "Error: Results must be given in the format \"x-y\",",
				" where x and y are integers.\n";
			return undef;
		}
	}

	# Check the remaining arguments are also integers:
	if(ref $args eq "HASH")
	{
		for my $arg(qw/player1_votes player2_votes/)
		{
			next unless(defined $args->{$arg});
			if($args->{$arg} !~ /^\d*$/)
			{
				print STDERR "Error: Argument '", $arg, "' must be an integer",
					".\n";
				return undef;
			}
		}

		# Finally, check if there are any unrecognised arguments, but just ignore
		# them instead of erroring out:
		my $is_valid = 0;
		for my $arg(keys %{$args})
		{
			for my $valid_arg(qw/player1_votes player2_votes scores_csv/)
			{
				if($arg eq $valid_arg)
				{
					$is_valid = 1;
					last;
				}
			}
			print STDERR "Warning: Ignoring unknown argument '", $arg, "'\n"
				unless($is_valid);
			$is_valid = 0;
		}
	}
	return 1;
}

=head1 AUTHOR

Alex Kerr, C<< <kirby at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-challonge at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Challonge::Match>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Challonge::Match


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Challonge::Match>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Challonge::Match>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Challonge::Match>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Challonge::Match/>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Challonge>

=item L<WWW::Challonge::Tournament>

=item L<WWW::Challonge::Participant>

=back


=head1 ACKNOWLEDGEMENTS


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

1; # End of WWW::Challonge::Match
