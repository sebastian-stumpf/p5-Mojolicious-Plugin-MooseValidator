package Mojolicious::Plugin::MooseValidator;
use Mojo::Base 'Mojolicious::Plugin';
use Try::Tiny;

our $VERSION = '0.01';

sub register {
  my ($self, $app) = @_;
  $app->helper(moose_validator => \&validate);
}

sub validate {
    my ($c, $pkg) = @_;
    my $meta = $pkg->meta;
    my $valid = $c->validation;

    my %args;
    foreach my $attr ($meta->get_all_attributes) {
        my $name = $attr->name;
        my $value = $c->param($name);
        my $ctype = $attr->type_constraint;

        if($attr->is_required && !$value) {
            $valid->error($name, 'required');
        }
        elsif($ctype and not $ctype->check($value)) {
            try {
                $args{$name} = $ctype->assert_coerce($value);
            }
            catch {
                $valid->error($name, $ctype->get_message($value));
            };
        }
        else {
            $args{$name} = $value;
        }
    }

    return if $valid->has_error;
    return $pkg->new(%args);
}

1;
__END__

=encoding utf8

=head1 NAME

Mojolicious::Plugin::MooseValidator - Mojolicious Plugin for validating parameters as Moose classes

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('MooseValidator');

  # Mojolicious::Lite
  plugin 'MooseValidator';

=head1 DESCRIPTION

L<Mojolicious::Plugin::MooseValidator> is a L<Mojolicious> plugin for validating parameters as Moose classes.

=head1 HELPERS

=head2 moose_validator

    {
        package Foobar;
        has param => (
            is => 'ro',
            isa => 'Str',
            required => 1
        );
    }

    my $moose = $c->validate_moose('Foobar');
    if($c->validation->has_error) {
        # could not create moose object
    }

Will create a new object if validation for all attributes is successful.
Will return nothing if the validation wasn't successful. Call
L<Mojolicious::Validator::Validation/"has_error"> to verify that the
validation succeeded.

=cut

=head1 METHODS

L<Mojolicious::Plugin::MooseValidator> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
