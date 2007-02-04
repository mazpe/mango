# $Id$
package Mango::Test;
use strict;
use warnings;

BEGIN {
    # little trick by Ovid to pretend to subclass+exporter Test::More
    use base qw/Test::Builder::Module Class::Accessor::Grouped/;
    use Test::More;
    use File::Spec::Functions qw/catfile catdir/;
    use DateTime ();

    @Mango::Test::EXPORT = @Test::More::EXPORT;

    __PACKAGE__->mk_group_accessors('inherited', qw/db_dir db_file/);
};

__PACKAGE__->db_dir(catdir('t', 'var'));
__PACKAGE__->db_file('mango.db');

## cribbed and modified from DBICTest in DBIx::Class tests
sub init_schema {
    my ($self, %args) = @_;
    my $db_dir  = $args{'db_dir'}  || $self->db_dir;
    my $db_file = $args{'db_file'} || $self->db_file;
    my $namespace = $args{'namespace'} || 'Mango::TestSchema';
    my $db = catfile($db_dir, $db_file);

    eval 'use DBD::SQLite';
    if ($@) {
       BAIL_OUT('DBD::SQLite not installed');

        return;
    };

    eval 'use Mango::Test::Schema';
    if ($@) {
        BAIL_OUT("Could not load Mango::Test::Schema: $@");

        return;
    };

    unlink($db) if -e $db;
    unlink($db . '-journal') if -e $db . '-journal';
    mkdir($db_dir) unless -d $db_dir;

    my $dsn = 'dbi:SQLite:' . $db;
    my $schema = Mango::Test::Schema->compose_namespace($namespace)->connect($dsn);
    $schema->storage->on_connect_do([
        'PRAGMA synchronous = OFF',
        'PRAGMA temp_store = MEMORY'
    ]);

    __PACKAGE__->deploy_schema($schema, %args);
    __PACKAGE__->populate_schema($schema, %args) unless $args{'no_populate'};

    return $schema;
};

sub deploy_schema {
    my ($self, $schema, %options) = @_;
    my $eval = $options{'eval_deploy'};

    eval 'use SQL::Translator';
    if (!$@ && !$options{'no_deploy'}) {
        eval {
            $schema->deploy();
        };
        if ($@ && !$eval) {
            die $@;
        };
    } else {
        open IN, catfile('t', 'sql', 'test.sqlite.sql');
        my $sql;
        { local $/ = undef; $sql = <IN>; }
        close IN;
        eval {
            ($schema->storage->dbh->do($_) || print "Error on SQL: $_\n") for split(/;\n/, $sql);
        };
        if ($@ && !$eval) {
            die $@;
        };
    };
};

sub clear_schema {
    my ($self, $schema, %options) = @_;

    foreach my $source ($schema->sources) {
        $schema->resultset($source)->delete_all;
    };
};

sub populate_schema {
    my ($self, $schema, %options) = @_;
    my $date = '2004-07-04 12:00:00';
    
    if ($options{'clear'}) {
        $self->clear_schema($schema, %options);
    };

    $schema->populate('Users', [
        [ qw/id username password created updated/ ],
        [1,'test1','password1',$date,$date],
        [2,'test2','password2',$date,$date],
        [3,'test3','password3',$date,$date],
    ]);

    $schema->populate('Roles', [
        [ qw/id name description created updated/ ],
        [1,'role1','Role1',$date,$date],
        [2,'role2','Role2',$date,$date],
    ]);

    $schema->populate('UsersRoles', [
        [ qw/user_id role_id/ ],
        [1,1],
        [1,2],
        [2,1],
    ]);

    $schema->populate('Profiles', [
        [ qw/id user_id first_name last_name created updated/ ],
        [1,1,'First1', 'Last1',$date,$date],
        [2,2,'First2', 'Last2',$date,$date],
    ]);

    $schema->populate('Carts', [
        [ qw/id user_id created updated/ ],
        [1,1,$date,$date],
        [2,undef,$date,$date],
    ]);

    $schema->populate('CartItems', [
        [ qw/id cart_id sku quantity price description created updated/ ],
        [1,1,'ABC-123',1,1.11,'SKU1',$date,$date],
        [2,1,'DEF-345',2,2.22,'SKU2',$date,$date],
        [3,2,'GHI-678',3,3.33,'SKU3',$date,$date],
    ]);

    $schema->populate('Wishlists', [
        [ qw/id user_id name description created updated/ ],
        [1,1,'Wishlist1','First Wishlist',$date,$date],
        [2,1,'Wishlist2','Second Wishlist',$date,$date],
        [3,2,'Wishlist3','Third Wishlist',$date,$date],
    ]);

    $schema->populate('WishlistItems', [
        [ qw/id wishlist_id sku quantity description created updated/ ],
        [1,1,'WABC-123',1,'WSKU1',$date,$date],
        [2,1,'WDEF-345',2,'WSKU2',$date,$date],
        [3,2,'WGHI-678',3,'WSKU3',$date,$date],
    ]);

    $schema->populate('Orders', [
        [ qw/id user_id type billtofirstname billtolastname billtoaddress1 billtoaddress2 billtoaddress3 billtocity billtostate billtozip billtocountry billtodayphone billtonightphone billtofax billtoemail comments created handling number shipmethod shipping shiptosameasbillto shiptofirstname shiptolastname shiptoaddress1 shiptoaddress2 shiptoaddress3 shiptocity shiptostate shiptozip shiptocountry shiptodayphone shiptonightphone shiptofax shiptoemail subtotal total updated tax/ ],
        [1,1,0,'Christopher','Laco','BillToAddress1','BillToAddress2','BillToAddress3','BillToCity','BillToState','BillToZip','BillToCountry','1-111-111-1111','2-222-222-2222','3-333-333-3333','mendlefarg@gmail.com','Comments',$date,8.95,'O123456789','UPS Ground',23.95,0,'Christopher','Laco','ShipToAddress1','ShipToAddress2','ShipToAddress3','ShipToCity','ShipToState','ShipToZip','ShipToCountry','4-444-444-4444','5-555-555-5555','6-666-666-6666','chrislaco@hotmail.com',5.55,37.95,$date, 6.66],
        [2,1,1,'Christopher','Laco','BillToAddress1','BillToAddress2','BillToAddress3','BillToCity','BillToState','BillToZip','BillToCountry','1-111-111-1111','2-222-222-2222','3-333-333-3333','mendlefarg@gmail.com','Comments',$date,8.95,'O123456789','UPS Ground',23.95,0,'Christopher','Laco','ShipToAddress1','ShipToAddress2','ShipToAddress3','ShipToCity','ShipToState','ShipToZip','ShipToCountry','4-444-444-4444','5-555-555-5555','6-666-666-6666','chrislaco@hotmail.com',5.55,37.95,$date, 6.66],
        [3,2,1,'Christopher','Laco','BillToAddress1','BillToAddress2','BillToAddress3','BillToCity','BillToState','BillToZip','BillToCountry','1-111-111-1111','2-222-222-2222','3-333-333-3333','mendlefarg@gmail.com','Comments',$date,8.95,'O123456789','UPS Ground',23.95,0,'Christopher','Laco','ShipToAddress1','ShipToAddress2','ShipToAddress3','ShipToCity','ShipToState','ShipToZip','ShipToCountry','4-444-444-4444','5-555-555-5555','6-666-666-6666','chrislaco@hotmail.com',5.55,37.95,$date, 6.66]
    ]);

    $schema->populate('OrderItems', [
        [ qw/id order_id sku quantity price total description created updated/ ],
        [1,1,'SKU1111',1,1.11,0,'Line Item SKU 1', $date,$date],
        [2,1,'SKU2222',2,2.22,0,'Line Item SKU 2', $date,$date],
        [3,2,'SKU3333',3,3.33,0,'Line Item SKU 3', $date,$date],
        [4,3,'SKU4444',4,4.44,0,'Line Item SKU 4', $date,$date],
        [5,3,'SKU1111',5,5.55,0,'Line Item SKU 5', $date,$date]
    ]);
};

1;
