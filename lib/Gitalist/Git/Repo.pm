use MooseX::Declare;

=head1 NAME

Gitalist::Git::Repo - Model of a repository directory

=head1 SYNOPSIS

    my $repo = Gitalist::Git::Repo->new( repo_dir => $Dir );
    my $project_list = $repo->projects;
    my $first_project = @$project_list[0];
    my $named_project = $repo->project('Gitalist');

=head1 DESCRIPTION

This class models a Gitalist Repo, which is a collection of
Projects (git repositories).  It is used for creating Project
objects to work with.

=cut


class Gitalist::Git::Repo {
    use MooseX::Types::Common::String qw/NonEmptySimpleStr/;
    use MooseX::Types::Path::Class qw/Dir/;
    use MooseX::Types::Moose qw/ArrayRef/;
    use aliased 'Gitalist::Git::Project';

=head1 ATTRIBUTES

=head2 repo_dir

L<Path::Class::Dir> for the root of the Repo.

=cut

    has repo_dir => (
        isa => Dir,
        is => 'ro',
        required => 1,
        coerce => 1,
    );

=head2 projects

An array of L<Gitalist::Git::Project> for each valid git repo
found in repo_dir.

=cut

    has projects => (
        is => 'ro',
        isa => ArrayRef['Gitalist::Git::Project'],
        required => 1,
        lazy_build => 1,
    );


=head1 METHODS

=head2 project

Returns a L<Gitalist::Git::Project> for the specified project
name.

=cut

    method project (NonEmptySimpleStr $project) {
        my $path = $self->repo_dir->subdir($project);
        die "Not a valid Project" unless $self->_is_git_repo($path);
        return Project->new( $self->repo_dir->subdir($project) );
    }


    method _build_projects {
        my $base = $self->repo_dir;
        my $dh = $base->open || die "Could not open $base";
        my @ret;
        while (my $file = $dh->read) {
            next if $file =~ /^.{1,2}$/;

            my $obj = $base->subdir($file);
            next unless -d $obj;
            next unless $self->_is_git_repo($obj);

            push @ret, $self->project($file);
        }

        return [sort { $a->name cmp $b->name } @ret];
    }

    # Determine whether a given directory is a git repo.
    method _is_git_repo ($dir) {
        return -f $dir->file('HEAD') || -f $dir->file('.git', 'HEAD');
    }
}                               # end class

__END__

=head1 SEE ALSO

L<Gitalist::Git::Project>

=head1 AUTHORS

See L<Gitalist> for authors.

=head1 LICENSE

See L<Gitalist> for the license.

=cut
