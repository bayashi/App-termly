package App::termly;
use strict;
use warnings;
use Getopt::Long qw/GetOptionsFromArray/;
use Encode qw/encode_utf8/;
use Web::Query::LibXML;
use Term::ANSIColor;
use IO::Pager::Buffered;

our $VERSION = '0.01';

sub run {
    my $self = shift;
    my @argv = @_;

    my $config = {};
    _merge_opt($config, @argv);

    IO::Pager::Buffered::open *STDOUT;

    _main($config);
}

sub _main {
    my $config = shift;

    my $word = $config->{word};

    print "[ $word ]\n";

    wq("http://term.ly/$word")->find("#detail")->each(sub{
        my $text = encode_utf8 $_->text;
        $text =~ s/(?:“|”)/"/g;
        $text =~ s![\s\n]+\n!\n!g;
        for my $line (split /\n/, $text) {
            $line =~ s!^\s{4}!!;
            if (!$config->{no_color} && $line =~ m!^[^\s]!) {
                print color('bold red');
                print "$line\n";
                print color('reset');
            }
            elsif (!$config->{no_color} && $line =~ m!^\s\s\s\s[^\s]!) {
                print color('bold yellow');
                print "$line\n";
                print color('reset');
            }
            else {
                print "$line\n";
            }
        }
    });
}

sub _merge_opt {
    my ($config, @argv) = @_;

    GetOptionsFromArray(
        \@argv,
        'color=s' => \$config->{no_color},
        'h|help'  => sub {
            _show_usage(1);
        },
        'v|version' => sub {
            print "$0 $VERSION\n";
            exit 1;
        },
    ) or _show_usage(2);

    $config->{word} = shift @argv;

    $config->{word} or _show_usage(2);
}

sub _show_usage {
    my $exitval = shift;

    require Pod::Usage;
    Pod::Usage::pod2usage(-exitval => $exitval);
}

__END__

=encoding UTF-8

=head1 NAME

App::termly - The CLI Interface for http://term.ly/


=head1 SYNOPSIS

    use App::termly;

    App::termly->run(@ARGV);


=head1 DESCRIPTION

App::termly provides L<termly> command.


=head1 REPOSITORY

=begin html

<a href="http://travis-ci.org/bayashi/App-termly"><img src="https://secure.travis-ci.org/bayashi/App-termly.png"/></a> <a href="https://coveralls.io/r/bayashi/App-termly"><img src="https://coveralls.io/repos/bayashi/App-termly/badge.png?branch=master"/></a>

=end html

App::termly is hosted on github: L<http://github.com/bayashi/App-termly>

I appreciate any feedback :D


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

L<termly>

L<http://term.ly/>

=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
