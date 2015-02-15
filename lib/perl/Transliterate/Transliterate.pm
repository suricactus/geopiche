package Transliterate::Transliterate;

use strict;
use utf8;

use Data::Dumper;
use Text::CSV::Encoded;

use constant MAP_FILE => 'data/map.csv';

binmode STDOUT, ":utf8";

sub new($$)
{
    my ($class, $options) = @_;
    my $self = {
        map => {},
        %$options,
    };

    open my $fh, "<:utf8", MAP_FILE
        or die("Unable to open map file: ", MAP_FILE);
   
    my $csv = new Text::CSV::Encoded->new({ encoding_in => "utf8" });

    while(my $row = $csv->getline($fh))
    {
        my @cols = map { $_ =~ s/\s+//; $_; } @$row;
        my $key = shift @cols;

        $$self{map}{$key} = \@cols;
    }
    $$self{map}{"*"} = ["*"];
    $$self{map}{"."} = ["."];

    bless $self, $class;    

    return $self;
}

sub tl($$)
{
    my ($self, $term) = @_;
    my @res = ("");
    
    $term =~ s/^\s|\s$//g;

    for my $char (split //, $term)
    {
        warn "UNKNOWN CHARACTER $char \n in $term" unless(defined $$self{map}{$char});

        # print Dumper $$self{map}{$char};

        my $size = scalar @res;
        while ($size-- > 0)
        {
            my $elem = shift @res;
           
            for my $sub (@{ $$self{"map"}{$char} })
            {
                push @res, $elem . $sub;
            }
        }
    }

    return @res;
}


1;
