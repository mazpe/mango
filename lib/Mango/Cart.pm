# $Id$
package Mango::Cart;
use strict;
use warnings;

BEGIN {
    use base qw/Handel::Cart/;
    use DateTime ();
};

## Yes, this isn't the preferred way. Sue me. I don't want the storage classes
## floating around this dist. If you make your own cart, feel free to do it the
## correct way. ;-)
__PACKAGE__->item_class('Mango::Cart::Item');
__PACKAGE__->storage->setup({
    autoupdate         => 0,
    currency_class     => 'Mango::Currency',
    schema_class       => 'Mango::Schema',
    schema_source      => 'Carts',
    constraints        => undef,
    default_values     => {
        created        => sub {DateTime->now},
        updated        => sub {DateTime->now}
    },
    validation_profile => undef
});
__PACKAGE__->result_iterator_class('Mango::Iterator');
__PACKAGE__->create_accessors;

sub type {
    
};

sub save {
    
};

sub update {
    my $self = shift;

    $self->updated(DateTime->now);
  
    return $self->SUPER::update(@_);
};

1;
__END__

=head1 NAME

Mango::Cart - Module for maintaining shopping cart contents

=head1 SYNOPSIS

    my $cart = $provider->create({
        user => 23
    });
    
    $cart->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });
    
    my $iterator = $cart->items;
    while (my $item = $iterator->next) {
        print $item->sku;
        print $item->price;
        print $item->total;
    };
    $item->subtotal;

=head1 DESCRIPTION

Mango::Cart is component for maintaining simple shopping cart data.

=head1 METHODS

=head2 add

=over

=item Arguments: \%data | $item

=back

Adds a new item to the current shopping cart and returns an instance of the
item class. You can either pass the item
data as a hash reference:

    my $item = $cart->add({
        sku      => 'SKU1234',
        quantity => 1,
        price    => 1.25
    });

or pass an existing cart item:

    $cart->add(
        $wishlist->items({sku => 'ABC-123'})->first
    );

When passing an existing cart item to add, all columns in the source item will
be copied into the destination item if the column exists in both the
destination and source, and the column isn't the primary key or the foreign
key of the item relationship.

=head2 clear

Deletes all items from the current cart.

    $cart->clear;

=head2 count

Returns the number of items in the cart object.

    my $numitems = $cart->count;

=head2 delete

=over

=item Arguments: \%filter

=back

Deletes the item matching the supplied filter from the current cart.

    $cart->delete({
        sku => 'ABC-123'
    });

=head2 items

=over

=item Arguments: \%filter [, \%options]

=back

Loads the current carts items matching the specified filter and returns a
L<Mango::Iterator|Mango::Iterator> in scalar context, or a list of items in
list context.

    my $iterator = $cart->items;
    while (my $item = $iterator->next) {
        print $item->sku;
    };
    
    my @items = $cart->items;

The following options are available:

=over

=item order_by

Order the items by the column(s) and order specified. This option uses the SQL
style syntax:

    my $items = $cart->items(undef, {order_by => 'sku ASC'});

=back

=head2 restore

=over

=item Arguments: \%filter [, $mode]

=item Arguments: $cart [, $mode]

=back

Copies (restores) items from a cart, or a set of carts back into the current
shopping cart. You may either pass in a hash reference containing the search
criteria of the shopping cart(s) to restore:

    $cart->restore({
        shopper => 'D597DEED-5B9F-11D1-8DD2-00AA004ABD5E',
        type    => CART_TYPE_SAVED
    });

or you can pass in an existing C<Mango::Cart> object or subclass.

    my $wishlist = Mango::Cart->search({
        id   => 23,
        type => CART_TYPE_SAVED
    })->first;
    
    $cart->restore($wishlist);

For either method, you may also specify the mode in which the cart should be
restored. The following modes are available:

=over

=item C<CART_MODE_REPLACE>

All items in the current cart will be deleted before the saved cart is restored
into it. This is the default if no mode is specified.

=item C<CART_MODE_MERGE>

If an item with the same SKU exists in both the current cart and the saved cart,
the quantity of each will be added together and applied to the same sku in the
current cart. Any price differences are ignored and we assume that the price in
the current cart has the more up to date price.

=item C<CART_MODE_APPEND>

All items in the saved cart will be appended to the list of items in the current
cart. No effort will be made to merge items with the same SKU and duplicates
will be ignored.

=back

=head2 id

Returns the id of the current cart.

    print $cart->id;

=head2 subtotal

Returns the current total price of all the items in the cart object as a
stringified L<Mango::Currency|Mango::Currency> object. This is equivalent to:

    my $iterator = $cart->items;
    my $subtotal = 0;
    while (my $item = $iterator->next) {
        $subtotal += $item->quantity*$item->price;
    };

=head2 created

Returns the date the cart was created as a DateTime object.

    print $cart->created;

=head2 updated

Returns the date the cart was last updated as a DateTime object.

    print $cart->updated;

=head2 update

Saves any changes to the cart back to the provider.

=head1 SEE ALSO

L<Mango::Cart::Item>, L<Mango::Schema::Cart>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
