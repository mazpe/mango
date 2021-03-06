#!perl -w
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More tests => 44;
    use Mango::Test::Catalyst ();
    use File::Spec::Functions qw/catdir catfile/;
    use File::Path qw/mkpath rmtree/;
    use File::Copy qw/copy/;
    use URI;
    use Cwd;
    use Scalar::Util qw/refaddr/;

    use_ok('Mango::Catalyst::Controller::Form');
    use_ok('Mango::Exception', ':try');
};



## put a temp root in var and copy some forms
{
    my $var = catdir('t', 'var');
    my $dir = catdir($var, qw/root forms form/);
    mkdir($var) unless -d $var;
    mkpath($dir);
    copy(catfile(qw/share forms admin products create.yml/), $dir);
    copy(catfile(qw/share forms admin products edit.yml/), $dir);

    $ENV{'MANGO_SHARE'} = catdir(Cwd::cwd, $var, 'root');
};


## load forms using class2prefix
{
    local $ENV{'LANG'} = 'en';

    my $c = Mango::Test::Catalyst->new({
        config => {
            home => catdir(qw/t var/)
        }
    });
    my $controller = $c->controller('Form');

    ## edit
    $c->request->uri(URI->new('http://foo/edit'));
    my $form = $controller->form('edit');
    isa_ok($form, 'Mango::Form');
    is($form->action, 'http://foo/edit');
    ok(!$form->submitted);

    $c->request->{'_submitted_admin_products_edit'} = 1;
    ok($form->submitted);
    my $results = $form->validate;
    isa_ok($results, 'Mango::Form::Results');
    ok(!$results->success);
    is_deeply($results->errors, [
        'CONSTRAINT_ID_NOT_BLANK',
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);

    ## create
    $c->request->uri(URI->new('http://foo/create'));
    $form = $controller->form('create');
    isa_ok($form, 'Mango::Form');
    is($form->action, 'http://foo/create');
    ok(!$form->submitted);

    $c->request->{'_submitted_admin_products_create'} = 1;
    ok($form->submitted);
    $results = $form->validate;
    isa_ok($results, 'Mango::Form::Results');
    ok(!$results->success);
    is_deeply($results->errors, [
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);


    ## action
    $c->action->reverse('form/edit');
    $c->request->uri(URI->new('http://foo/edit/new'));
    delete $c->request->{'_submitted_admin_products_edit'};
    $form = $controller->form;
    isa_ok($form, 'Mango::Form');
    is($form->action, 'http://foo/edit/new');
    ok(!$form->submitted);

    $c->request->{'_submitted_admin_products_edit'} = 1;
    ok($form->submitted);
    $results = $form->validate;
    isa_ok($results, 'Mango::Form::Results');
    ok(!$results->success);
    is_deeply($results->errors, [
        'CONSTRAINT_ID_NOT_BLANK',
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);


    rmtree(catdir('t', 'var'));
};


## load forms using form_directory
{
    local $ENV{'LANG'} = 'en';

    Mango::Catalyst::Controller::Form->config(
        form_directory => catdir(qw/share forms admin products/)
    );
    my $c = Mango::Test::Catalyst->new({
        config => {
            home => catdir(qw/t var/)
        }
    });
    my $controller = $c->controller('Form');

    ## edit
    $c->request->uri(URI->new('http://foo/edit'));
    my $form = $controller->form('edit');
    isa_ok($form, 'Mango::Form');
    is($form->action, 'http://foo/edit');
    ok(!$form->submitted);

    $c->request->{'_submitted_admin_products_edit'} = 1;
    ok($form->submitted);
    my $results = $form->validate;
    isa_ok($results, 'Mango::Form::Results');
    ok(!$results->success);
    is_deeply($results->errors, [
        'CONSTRAINT_ID_NOT_BLANK',
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);

    ## create
    $c->request->uri(URI->new('http://foo/create'));
    $form = $controller->form('create');
    isa_ok($form, 'Mango::Form');
    is($form->action, 'http://foo/create');
    ok(!$form->submitted);

    $c->request->{'_submitted_admin_products_create'} = 1;
    ok($form->submitted);
    $results = $form->validate;
    isa_ok($results, 'Mango::Form::Results');
    ok(!$results->success);
    is_deeply($results->errors, [
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);


    ## action
    $c->action->reverse('form/edit');
    $c->request->uri(URI->new('http://foo/edit/new'));
    delete $c->request->{'_submitted_admin_products_edit'};
    $form = $controller->form;
    isa_ok($form, 'Mango::Form');
    is($form->action, 'http://foo/edit/new');
    ok(!$form->submitted);

    $c->request->{'_submitted_admin_products_edit'} = 1;
    ok($form->submitted);
    $results = $form->validate;
    isa_ok($results, 'Mango::Form::Results');
    ok(!$results->success);
    is_deeply($results->errors, [
        'CONSTRAINT_ID_NOT_BLANK',
        'CONSTRAINT_SKU_NOT_BLANK',
        'The name field is required.',
        'CONSTRAINT_DESCRIPTION_NOT_BLANK',
        'CONSTRAINT_PRICE_NOT_BLANK'
    ]);
};
