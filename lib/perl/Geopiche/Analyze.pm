package Geopiche::Analyze;

use strict;
use utf8;

use Data::Dumper;
use JSON;
use Text::CSV::Encoded;
use Transliterate::Transliterate;

#binmode STDOUT, ":utf8";

sub new()
{
    my ($class, $options) = @_;
    my $self = {
        source => undef,
        source_encoding => 'ISO 8859-1',
        terms => undef,
        terms_encoding => "utf8",
        %$options,
    };

    bless $self, $class;    

    return $self;
}


sub read()
{
    my ($self) = @_;
    my $csv = new Text::CSV::Encoded->new({ encoding_in => $$self{source_encoding} });
    my @terms = $self->GetTerms();
    open my $fh, "<:encoding($$self{source_encoding})", "$$self{source}" or die "$$self{source}: $!";
    # Remove first line
    $csv->getline( $fh );
    
    my $index;
    my $retries; 
    my @result;
    while ( my $row = $csv->getline( $fh ) || $retries++ < 10) 
    {
        $index++;
        
        next unless ref $row eq "ARRAY";
        print STDERR "$index $$row[1]\n";
        
        $retries = 0;
        
        for my $term (@terms)
        {
            for my $tl (@{ $$term{tl} })
            {
                if( $self->StringCompare( $$row[1], $tl ) )
                {
                    print STDERR "MATCH: $$row[1] == $tl\n";
                    push @result, {
                        name => $$row[1],
                        accent_name => $$row[2],
                        latLng => [ $$row[5], $$row[6] ],
                        original_match => $$term{original},
                        term => $$term{term},
                    };
                    
                    last;
                    ## TODO allow more than one match
                }
            }
        }
    }
        
    print encode_json \@result;
}

# TODO make it work
sub MCELoop($)
{
    my ($self) = @_;
    my $csv = new Text::CSV::Encoded->new({ encoding_in => $$self{source_encoding}, });
    my @terms = $self->GetTerms();
    open my $fh, "<:encoding($$self{source_encoding})", "$$self{source}" or die "$$self{source}: $!";
# Remove first line
    $csv->getline( $fh );

    my $index;
    my $retries; 
    my @result;

    use MCE::Loop 
            max_workers => 8, 
            chunk_size => 'auto' 
    ;

    @result = mce_loop_f {
        my ($mce, $chunk, $mce_index) = @_;
    
        while ( my $line = shift $chunk) 
        {
            $index++;
            $csv->parse($line);
            my $row = [ $csv->fields ];

            #MCE->print(\*STDERR, "$index $$row[1]\n");

            for my $term (@terms)
            {
                for my $tl (@{ $$term{tl} })
                {
                    if( $self->StringCompare( $$row[1], $tl ) )
                    {
                        MCE->print( \*STDERR, "MATCH $index: $$row[1] =~ $tl\n");
                        MCE->gather( {
                            name => $$row[1],
                                 accent_name => $$row[2],
                                 latLng => [ $$row[5], $$row[6] ],
                                 original_match => $$term{original},
                                 term => $$term{term},
                        } );

                        last;
## TODO allow more than one match
                    }
                }
            }
        }
    } $fh;
    
    print JSON->new->space_after->encode(\@result);
}

sub GetTerms($)
{
    my ($self) = @_;
    my @terms;
     
    open my $fh, "<:encoding($$self{terms_encoding})", "$$self{terms}" or die "$$self{terms}: $!";  

    my $tl = Transliterate::Transliterate->new({});

    while(<$fh>)
    {
        chomp $_;
        my $term = my $pattern = my $original = $_;
        $term =~ s/\*//g;
        $pattern =~ s/\*/.*/g;

        my @transliterated = $tl->tl($pattern);
        
        push @terms, {
            term => $term,
            pattern => $pattern,
            original => $original,
            tl => \@transliterated,
        };
    }

    return @terms;
}
sub StringCompare($$$)
{
    my ($self, $compare, $pattern) = @_;
    my $q_compare = quotemeta $compare;

    return $q_compare =~ /\b$pattern\b/;
}


sub StringCompareOld($$$)
{
    my ($self, $compare, $term) = @_;
    my $q_compare = quotemeta $compare;
    
    my $tl_term = join '|', values $$term{tl_terms};
    return $compare =~ /$tl_term/;
}

sub SoundCompare($$$)
{

}

1;
