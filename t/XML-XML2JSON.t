# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl XML-XML2JSON.t'

#########################

use strict;

use Test::More tests => 2;

BEGIN { use_ok('XML::XML2JSON') };

#########################

my $XML = qq|<?xml version="1.0" encoding="UTF-8" ?>
<test>
	<data attr1="test">some test text</data>
</test>
|;

diag "\nChecking for compatible JSON modules (you need at least one):\n";

my $FoundModules = 0;

$FoundModules++ if &check_module('JSON::Syck');
$FoundModules++ if &check_module('JSON::XS');
$FoundModules++ if &check_module('JSON');
$FoundModules++ if &check_module('JSON::DWIW');

diag "compatible JSON modules found: $FoundModules";

ok($FoundModules);

sub check_module
{
	my ($Module) = @_;
	
	diag "checking for $Module...";
	
	eval "use $Module; 1;";
	if ($@)
	{
		diag "NOT FOUND";
		return 0;
	}
	else
	{
		eval
		{
			my $XML2JSON = XML::XML2JSON->new( module=>$Module );
			my $JSON = $XML2JSON->convert($XML);
			
			# check attribute
			die "attribute test failed" unless $JSON =~ /["']\@attr1["']\s*:\s*["']test["']/;

			# check element text
			die "text test failed" unless $JSON =~ /["']\$t["']\s*:\s*["']some test text["']/;
		};
		if ($@)
		{
			diag "FAILED: $@";
			return 0;
		}
	}
	
	diag "OK";
	return 1;
}
