use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Data::Dumper;

plugin 'MooseValidator';

{
    package Foo;
    use Moose;
    has param => (
        is => 'ro',
        isa => 'Str',
        required => 1
    );
}

{
    package Bar;
    use Moose;
    has param => (
        is => 'ro',
        isa => 'Int',
        required => 1
    );
}

{
    package Coerced;
    use Moose;
    has newparam => (
        is => 'ro',
        isa => 'Str',
        required => 1
    );
}

{
    package Baz;
    use Moose;
    use Moose::Util::TypeConstraints;
    class_type 'Coerced';
    coerce 'Coerced' => from 'Str' => via { Coerced->new(newparam => $_) };
    has param => (
        is => 'ro',
        isa => 'Coerced',
        required => 1,
        coerce => 1
    );
}

get '/missing' => sub {
    my $c = shift;
    ok(!$c->moose_validator('Foo'), 'param is required');
    ok($c->validation->has_error, 'validation has error');
    $c->render(text => '');
};

get '/ok/:param' => sub {
    my $c = shift;
    my $foo = $c->moose_validator('Foo');
    isa_ok($foo, 'Foo');
    is($foo->param, 'param', 'has correct parameter');
    $c->render(text => '');
};

get '/wrong/int/:param' => sub {
    my $c = shift;
    my $bar = $c->moose_validator('Bar');
    ok(!$bar, 'no return value');
    ok($c->validation->has_error, 'validation has error');
    like($c->validation->error('param'), qr/^Validation failed for/, 'correct validation error');
    $c->render(text => '');
};

get '/int/:param' => sub {
    my $c = shift;
    my $bar = $c->moose_validator('Bar');
    isa_ok($bar, 'Bar');
    is($bar->param, 123, 'integer value');
    $c->render(text => '');
};

get '/coerced/:param' => sub {
    my $c = shift;
    my $baz = $c->moose_validator('Baz');
    isa_ok($baz, 'Baz');
    is($baz->param->newparam, 'param', 'coerced string');
    $c->render(text => '');
};

my $t = Test::Mojo->new;
$t->get_ok('/missing');
$t->get_ok('/ok/param');
$t->get_ok('/wrong/int/param');
$t->get_ok('/int/123');
$t->get_ok('/coerced/param');
done_testing();
