package Dist::Zilla::Role::CheckPackageDeclared;

# DATE
# VERSION

use 5.010001;
use Moose::Role;
with 'Dist::Zilla::Role::ModuleMetadata';

my $cache; # hash. key=package name, value = first file that declares it

sub is_package_declared {
    my ($self, $package) = @_;

    unless ($cache) {
        $cache = {};
        for my $file ($self->zilla->find_files(':InstallModules')) {
            $self->log_fatal([ 'Could not decode %s: %s', $file->name, $file->added_by ])
                if $file->can('encoding') and $file->encoding eq 'bytes';
            my @packages = $self->module_metadata_for_file($file)->packages_inside;
            $cache->{$_} //= $file->name for @packages;
        }
    }

    exists $cache->{$package} ? 1:0;
}

no Moose::Role;
1;
# ABSTRACT: Role to check if a package is provided by your distribution

=head1 METHODS

=head2 is_package_declared

Usage: my $declared = $obj->is_package_declared($package) => bool

Return true when C<$package> is declared by one of the modules in the
distribution. L<Module::Metadata> is used to extract declared packages in a
file.


=head1 SEE ALSO

L<Module::Metadata>

L<Dist::Zilla::Plugin::CheckSelfDependency>

L<Dist::Zilla::Plugin::RemoveSelfDependency>
