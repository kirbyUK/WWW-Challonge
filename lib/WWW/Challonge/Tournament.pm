package WWW::Challonge::Tournament;

use 5.006;
use strict;
use warnings;
use JSON qw/to_json from_json/;

sub __is_kill;
sub __tournament_args_are_valid;

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

=head2 update

Updates specific attributes of a tournament. For a full list, see
L<WWW::Challonge/create>. Unlike that method, however, all of the arguments
are optional.

	$t->update({
		name => "sample_tournament_2",
		type => "swiss",
	});

=cut

sub update
{
	my $self = shift;
	my $args = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament url:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Check the arguments and values are valid:
	return undef
		unless(WWW::Challonge::Tournament::__tournament_args_are_valid($args));

	# Add the API key and put everything else in a 'tournament' hash:
	my $params = { api_key => $key, tournament => $args };

	# Make the PUT request:
	$client->PUT("/tournaments/$url.json", to_json($params),
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

	# If so, update the object's store of the tournament:
	$self->{tournament} = from_json($client->responseContent)->{tournament};
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

	# Set the tournament to dead to prevent further operations:
	$self->{alive} = 0;
}

=head2 process_check_ins

This should be invoked after a tournament's check-in window closes, but before
the tournament is started. It then does the following:

=over 4

=item 1

Marks participants who have not checked in as inactive.

=item 2

Moves inactive participants to the bottom seeds.

=item 3

Transitions the tournament state from "checking_in" to "checked_in".

=end

	$t->process_check_ins;

=cut

sub process_check_ins
{
	my $self = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament URL:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Send the API key:
	my $params = { api_key => $key };

	# Make the POST call:
	$client->POST("/tournaments/$url/process_check_ins.json", to_json($params),
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

	# If so, update the object's store of the tournament:
	$self->{tournament}->{state} = "checked_in";
}

=head2 abort_check_in

Aborts the check-in process if the tournament's status is currently
"checking_in" or "checked_in". This is useful as you cannot edit the
tournament's start time during this state. It does the following:

=over 4

=item 1

Makes all participants active and clears their "checked_in_at" times.

=item 2

Sets the tournament state from "checking_in" or "checked_in" to "pending".

=end

	$t->abort_check_in;

=cut

sub abort_check_in
{
	my $self = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament URL:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Send the API key:
	my $params = { api_key => $key };

	# Make the POST call:
	$client->POST("/tournaments/$url/abort_check_in.json", to_json($params),
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

	# If so, update the object's store of the tournament:
	$self->{tournament}->{state} = "pending";
}

=head2 start

Starts a tournament, opening up matches for score reporting. The tournament
must have at least 2 participants. If successful, sets the status of the
tournament to "in_progress".

	$t->start;

=cut

sub start
{
	my $self = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament URL:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Send the API key:
	my $params = { api_key => $key };

	# Make the POST call:
	$client->POST("/tournaments/$url/start.json", to_json($params),
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

	# If so, update the object's store of the tournament:
	$self->{tournament}->{state} = "in_progress";
}

=head2 finalize

Finalises a tournament that has had all match scores submitted, rendering the
results permenant. If successful, it sets the status to "ended".

	$t->finalize;

=cut

sub finalize
{
	my $self = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament URL:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Send the API key:
	my $params = { api_key => $key };

	# Make the POST call:
	$client->POST("/tournaments/$url/finalize.json", to_json($params),
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

	# If so, update the object's store of the tournament:
	$self->{tournament}->{state} = "ended";
}

=head2 reset

Resets an "in_progress" tournament, deleting all match records. You can add,
remove or edit users before starting again.

	$t->reset;

=cut

sub reset
{
	my $self = shift;

	# Do not operate on a dead tournament:
	return __is_kill unless($self->{alive});

	# Get the key, REST client and tournament URL:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Send the API key:
	my $params = { api_key => $key };

	# Make the POST call:
	$client->POST("/tournaments/$url/reset.json", to_json($params),
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

	# If so, update the object's store of the tournament:
	$self->{tournament}->{state} = "ended";
}

=head2 attributes

Gets all the attributes of the tournament in a hashref. Contains the following
fields.

=over 4

=item accepting_predictions

=item accept_attachments

=item allow_participant_match_reporting

=item anonymous_voting

=item category

=item check_in_duration

=item completed_at

=item created_at

=item created_by_api

=item credit_capped

=item description

=item description_source

=item full_challonge_url

=item game_id

=item game_name

=item group_stages_enabled

=item group_stages_were_started

=item hide_forum

=item hide_seeds

=item hold_third_place_match

=item id

=item live_image_url

=item max_predictions_per_user

=item name

=item notify_users_when_match_opens

=item notify_users_when_the_tournament_ends

=item open_signup

=item participants_count

=item participants_locked

=item participants_swappable

=item prediction_method

=item predictions_opened_at

=item private

=item progress_meter

=item pts_for_bye

=item pts_for_game_tie

=item pts_for_game_win

=item pts_for_match_tie

=item pts_for_match_win

=item quick_advance

=item ranked_by

=item review_before_finalizing

=item require_score_agreement

=item rr_pts_for_game_tie

=item rr_pts_for_game_win

=item rr_pts_for_match_tie

=item rr_pts_for_match_win

=item sequential pairings

=item show_rounds

=item signup_cap

=item sign_up_url

=item start_at

=item started_at

=item started_checking_in_at

=item state

=item swiss_rounds

=item subdomain

=item teams

=item team_convertable

=item tie_breaks

=item tournament_type

=item updated_at

=item url

=end

	my $attr = $t->attributes;
	print $attr->{name}, "\n";

=cut

sub attributes
{
	my $self = shift;

	# Get the key, REST client and url:
	my $key = $self->{key};
	my $client = $self->{client};
	my $url = $self->{tournament}->{url};

	# Get the most recent version:
	$client->GET("/tournaments/$url.json?api_key=$key");

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

	# Save the most recent version and return it:
	$self->{tournament} = from_json($client->responseContent)->{tournament};
	return $self->{tournament};
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

=head2 __tournament_args_are_valid

Checks if the passed arguments and values are valid for creating or updating
a tournament.

=cut

sub __tournament_args_are_valid
{
	my $args = shift;

	# The possible parameters, grouped together by the kind of input they take.
	# This is used for input vaidation.
	my %valid_args = (
		string => [
			"name",
			"tournament_type",
			"url",
			"subdomain",
			"description",
			"game_name",
			"ranked_by",
		],
		integer => [
			"swiss_rounds",
			"signup_cap",
			"check_in_duration",
		],
		decimal => [
			"pts_for_match_win",
			"pts_for_match_tie",
			"pts_for_game_win",
			"pts_for_game_tie",
			"pts_for_bye",
			"rr_pts_for_match_win",
			"rr_pts_for_match_tie",
			"rr_pts_for_game_win",
			"rr_pts_for_game_tie",
		],
		bool => [
			"open_signup",
			"hold_third_place_match",
			"accept_attachments",
			"hide_forum",
			"show_rounds",
			"private",
			"notify_users_when_matches_open",
			"notify_users_when_the_tournament_ends",
			"sequential_pairings",
		],
		datetime => [
			"start_at"
		],
	);

	# Validate the inputs:
	for my $arg(@{$valid_args{string}})
	{
		next unless(defined $args->{$arg});
		# Most of the string-based arguments require individual validation
		# based on what they are:
		if($arg =~ /^name$/)
		{
			if(length $args->{$arg} > 60)
			{
				print STDERR "Error: Name '", $args->{$arg}, " is longer than ",
					"60 characters";
				return undef;
			}
		}
		elsif($arg =~ /^tournament_type$/)
		{
			if($args->{$arg} !~ /^((single|double) elimination)|(round robin)|
				(swiss)$/i)
			{
				print STDERR "Error: Value '", $args->{$arg}, "' is invalid ",
					"for argument '", $arg, "'\n";
				return undef;
			}
		}
		elsif($arg =~ /^url$/)
		{
			if($args->{$arg} !~ /^[a-zA-Z0-9_]*$/)
			{
				print STDERR "Error: Value '", $args->{$arg}, "' is not a ",
					"valid URL.\n";
				return undef;
			}
		}
		elsif($arg =~ /^ranked_by$/)
		{
			if($args->{$arg} !~ /^((match|game) wins)|
				(points (scored|difference))|custom/i)
			{
				print STDERR "Error: Value '", $args->{$arg}, "' is invalid ",
					"for argument '", $arg, "'\n";
				return undef;
			}
		}
	}
	for my $arg(@{$valid_args{integer}})
	{
		next unless(defined $args->{$arg});
		# Make sure the argument is an integer:
		if($args->{$arg} !~ /^\d*$/)
		{
			print STDERR "Error: Value '", $args->{$arg}, "' is not a valid ",
				"integer for argument '", $arg, "'\n";
			return undef;
		}
	}
	for my $arg(@{$valid_args{decimal}})
	{
		next unless(defined $args->{$arg});
		# Make sure the argument is an integer or decimal:
		if($args->{$arg} !~ /^\d*\.?\d*$/)
		{
			print STDERR "Error: Value '", $args->{$arg}, "' is not a valid ",
				"decimal for argument '", $arg, "'\n";
			return undef;
		}
		else
		{
			$args->{$arg} = sprintf("%.1f", $args->{$arg});
		}
	}
	for my $arg(@{$valid_args{boolean}})
	{
		next unless(defined $args->{$arg});
		# Make sure the argument is true or false:
		if($args->{$arg} !~ /^(true|false)$/i)
		{
			print STDERR "Error: Value '", $args->{$arg}, "' is not a valid ",
				"for argument '", $arg, "'. It should be 'true' or 'false'.\n";
			return undef;
		}
	}
	for my $arg(@{$valid_args{datetime}})
	{
		next unless(defined $args->{$arg});
		# Make sure the argument is a valid datetime:
#		if($args->{$arg} !~ /^$/)
#		{
#			print STDERR "Error: Value '", $args->{$arg}, "' is not a valid ",
#				"for argument '", $arg, "'. It should be 'true' or 'false'.\n";
#			return undef;
#		}
	}

	# Finally, check if there are any unrecognised arguments, but just ignore
	# them instead of erroring out:
	my @accepted_inputs = (
		@{$valid_args{string}},
		@{$valid_args{integer}},
		@{$valid_args{decimal}},
		@{$valid_args{boolean}},
		@{$valid_args{datetime}}
	);
	my $is_valid = 0;
	for my $arg(keys %{$args})
	{
		for my $valid_arg(@accepted_inputs)
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
	return 1;
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
