package MooseX::Meta::TypeCoercion::Structured;

use Moose;
extends 'Moose::Meta::TypeCoercion';

=head1 NAME

MooseX::Meta::TypeCoercion::Structured - Coerce structured type constraints.

=head1 DESCRIPTION

We need to make sure we can properly coerce the structure elements inside a
structured type constraint.

This class is TDB once we fully understand the requirements for deep coercions.

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

1;