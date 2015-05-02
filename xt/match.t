#!perl -T
use strict;
use warnings;
use WWW::Challonge;
use Test::More tests => 2;

# Check if compiles:
BEGIN
{
	require_ok("WWW::Challonge::Participant") || BAIL_OUT();
}

diag("Testing WWW::Challonge::Participant $WWW::Challonge::Participant::VERSION, Perl $], $^X");

SKIP:
{
	skip "Requires 'key' file with API key to run xt tests", 1
		unless( -f "xt/key");

	open my $file, '<', "xt/key" or die "Error: Cannot open key file: $!";
	chomp(my $key = <$file>);

	# Create a new tournament and two participants:
	my $c = WWW::Challonge->new($key);
	my $url = "";
	my @chars = ("a".."z", "A".."Z", "_");
	$url .= $chars[rand @chars] for(1..20);
	my $t = $c->create({
		name => "Perl Test",
		url => $url,
	});
	$t->create_participant({ name => "alice" });
	$t->create_participant({ name => "bob" });
	$t->start;

	# Get the match:
	my $test;
	subtest "index works" => sub
	{
		my @matches = $t->match_index;
		is(@matches, 1, "Index gives one match");
		isa_ok($matches[0], "WWW::Challonge::Match");
	};
}
