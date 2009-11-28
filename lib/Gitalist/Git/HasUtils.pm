package Gitalist::Git::HasUtils;
use Moose::Role;
use Gitalist::Git::Util;
use namespace::autoclean;

sub BUILD {}
after BUILD => sub {
    my $self = shift;
    # Force value build. A little convoluted as we don't have an accessor :)
    $self->_util;
};

has _util => ( isa => 'Gitalist::Git::Util',
               is => 'ro',
               lazy_build => 1,
               handles => [ 'run_cmd',
                            'run_cmd_fh',
                            'run_cmd_list',
                            'get_gpp_object',
                            'gpp',
                        ],
           );

sub _build__util { confess(shift() . " cannot build _util") }

1;

__END__

=head1 AUTHORS

See L<Gitalist> for authors.

=head1 LICENSE

See L<Gitalist> for the license.

=cut
