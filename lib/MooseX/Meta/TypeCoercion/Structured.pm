package ## Hide from PAUSE
 MooseX::Meta::TypeCoercion::Structured;

use Moose;
extends 'Moose::Meta::TypeCoercion';

=head1 NAME

MooseX::Meta::TypeCoercion::Structured - Coerce structured type constraints.

=head1 DESCRIPTION

We need to make sure we can properly coerce the structure elements inside a
structured type constraint.  However requirements for the best way to allow
this are still in flux.  For now this class is a placeholder.

=head1 METHODS

This class defines the following methods.

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Moose>, L<Moose::Meta::TypeCoercion>

=head1 AUTHOR

John Napiorkowski, C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
