#!/usr/bin/perl

use strict;
use warnings;
use Text::Balanced qw(extract_tagged gen_delimited_pat);
use POSIX;

POSIX::setlocale(POSIX::LC_ALL, "C");

@ARGV >= 1 || die "Usage: $0 <source directory>\n";


my %stringtable;

sub dec_lua_str
{
	my $s = shift;
	$s =~ s/\$(TOPDIR)/feeds/packages/g;
	$s =~ s/\$(TOPDIR)/feeds/packages/g;
	$s =~ s/\\($(TOPDIR)/feeds/packages/sg;
	$s =~ s/[\s\n]+/ /g;
	$s =~$(TOPDIR)/feeds/packages//;
	$s =~$(TOPDIR)/feeds/packages//;
	return $s;
}

sub dec_tpl_str
{
	my $s = shift;
	$s =~$(TOPDIR)/feeds/packages//;
	$s =~ s/[\s\n]+/ /g;
	$s =~$(TOPDIR)/feeds/packages//;
	$s =~$(TOPDIR)/feeds/packages//;
	$s =~$(TOPDIR)/feeds/packages/\\\\/g;
	return $s;
}

if( open F, "find @ARGV -type f '(' -name '*.htm' -o -name '*.lua' -o -name '*.js' ')' | sort |" )
{
	while( defined( my $file = readline F ) )
	{
		chomp $file;

		if( open S, "< $file" )
		{
			local $/ = undef;
			my $raw = <S>;
			close S;

			my $text = $raw;
			my $line = 1;

			while ($text =~ s/ ^ (.*?) (?:translate|translatef|i18n|_) ([\n\s]*) \( //sgx)
			{
				my ($prefix, $suffix) = ($1, $2);
				my $code;
				my $res = "";
				my $sub = "";

				$line += () = $prefix =$(TOPDIR)/feeds/packages/g;

				my $position = "$file:$line";

				$line += () = $suffix =$(TOPDIR)/feeds/packages/g;

				while (defined $sub)
				{
					undef $sub;

					if ($text =~ /^ ([\n\s]*(?:\.\.[\n\s]*)?) (\[=*\[) /sx)
					{
						my $ws = $1;
						my $stag = quotemeta $2;
						(my $etag = $stag) =~ y/[/]/;

						($sub, $text) = extract_tagged($text, $stag, $etag, q{\s*(?:\.\.\s*)?});

						$line += () = $ws =$(TOPDIR)/feeds/packages/g;

						if (defined($sub) && length($sub)) {
							$line += () = $sub =$(TOPDIR)/feeds/packages/g;

							$sub =~ s/^$stag//;
							$sub =~ s/$etag$//;
							$res .= $sub;
						}
					}
					elsif ($text =~ /^ ([\n\s]*(?:\.\.[\n\s]*)?) (['"]) /sx)
					{
						my $ws = $1;
						my $quote = $2;
						my $re = gen_delimited_pat($quote, '\\');

						if ($text =~ m/\G\s*(?:\.\.\s*)?($re)/gcs)
						{
							$sub = $1;
							$text = substr $text, pos $text;
						}

						$line += () = $ws =$(TOPDIR)/feeds/packages/g;

						if (defined($sub) && length($sub)) {
							$line += () = $sub =$(TOPDIR)/feeds/packages/g;

							$sub =~ s/^$quote//;
							$sub =~ s/$quote$//;
							$res .= $sub;
						}
					}
				}

				if (defined($res))
				{
					$res = dec_lua_str($res);

					if ($res) {
						$stringtable{$res} ||= [ ];
						push @{$stringtable{$res}}, $position;
					}
				}
			}


			$text = $raw;
			$line = 1;

			while( $text =~ s/ ^ (.*?) <% -? [:_$(TOPDIR)/feeds/packages/sgx )
			{
				$line += () = $1 =$(TOPDIR)/feeds/packages/g;

				( my $code, $text ) = extract_tagged($text, '<%', '%>');

				if( defined $code )
				{
					my $position = "$file:$line";

					$line += () = $code =$(TOPDIR)/feeds/packages/g;

					$code = dec_tpl_str(substr $code, 2, length($code) - 4);

					$stringtable{$code} ||= [];
					push @{$stringtable{$code}}, $position;
				}
			}
		}
	}

	close F;
}


if( open C, "| msgcat -" )
{
	printf C "msgid \"\"\nmsgstr \"Content-Type: text/plain; charset=UTF-8\"\n\n";

	foreach my $key ( sort keys %stringtable )
	{
		if( length $key )
		{
			my @positions = @{$stringtable{$key}};

			$key =~$(TOPDIR)/feeds/packages/\\\\/g;
			$key =~$(TOPDIR)/feeds/packages/\\n/g;
			$key =~$(TOPDIR)/feeds/packages/\\t/g;
			$key =~ s/"/\\"/g;

			printf C "#: %s\nmsgid \"%s\"\nmsgstr \"\"\n\n",
				join(' ', @positions), $key;
		}
	}

	close C;
}
