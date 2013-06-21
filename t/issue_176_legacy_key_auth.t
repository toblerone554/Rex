BEGIN {
   use Test::More tests => 24;
   use Data::Dumper;
   use_ok 'Rex';
   use_ok 'Rex::Commands';
   use_ok 'Rex::Config';
   use_ok 'Rex::Group::Entry::Server';
   Rex::Commands->import;
};

Rex::Config::read_ssh_config_file("t/issue_176_legacy_ssh.config");

#
# legacy tests
#
# user set in Rexfile
# should be used on per task basis


# no user set, so use $ENV{USER}
task "t-1", sub {};

task "t0", sub {};

user "root";
password "test";
key_auth;

task "t1", sub {};


user "foo";
password "bar";

group s1 => "srv1", "srv2";

# should have no affect in legacy mode
auth for => "s1", 
      user => "s1root",
      password => "s1pass";

task "t2", sub {};

task "t3", sub {};

task "t4", group => "s1", sub {};

task "t5", sub {};

auth for => "t3",
      user => "bazzinga",
      password => "fxxbxx";


my $srv1 = Rex::Group::Entry::Server->new(name => "myhost01");

# this host should use user blah
my $srv2 = Rex::Group::Entry::Server->new(name => "foo");

my $tm1 = Rex::TaskList->create()->get_task("t-1");
my %con_hash_tm1 = $tm1->build_connect_hash($srv1);

my $t0 = Rex::TaskList->create()->get_task("t0");
my %con_hash_t0 = $t0->build_connect_hash($srv2);

my $t1 = Rex::TaskList->create()->get_task("t1");
my %con_hash_t1 = $t1->build_connect_hash($srv1);

my $t2 = Rex::TaskList->create()->get_task("t2");
my %con_hash_t2 = $t2->build_connect_hash($srv1);

my $t3 = Rex::TaskList->create()->get_task("t3");
my %con_hash_t3 = $t3->build_connect_hash($srv1);

my $t4 = Rex::TaskList->create()->get_task("t4");
my @server_t4 = @{ $t4->server };
my %con_hash_t4 = $t4->build_connect_hash($server_t4[0]);

my $t5 = Rex::TaskList->create()->get_task("t5");
my %con_hash_t5 = $t4->build_connect_hash($srv2);

print STDERR Dumper(\%con_hash_t5);


ok($con_hash_tm1{user} eq $ENV{USER}, "legacy test - got user $ENV{USER} - from ENV");
ok($con_hash_tm1{auth_type} eq "key", "legacy test - got auth_type pass for t-1");

ok($con_hash_t0{user} eq "blah", "legacy test - got user blah - from ssh_config override");
ok($con_hash_t0{auth_type} eq "key", "legacy test - got auth_type pass for t0");

ok($con_hash_t1{user} eq "root", "legacy test - got user root");
ok($con_hash_t1{password} eq "test", "legacy test - got password test");
ok($con_hash_t1{auth_type} eq "key", "legacy test - got auth_type pass for t1");

ok($con_hash_t2{user} eq "foo", "legacy test - got user foo");
ok($con_hash_t2{password} eq "bar", "legacy test - got password bar");
ok($con_hash_t2{auth_type} eq "key", "legacy test - got auth_type pass for t2");

ok($con_hash_t3{user} eq "bazzinga", "legacy test - got user bazzinga");
ok($con_hash_t3{password} eq "fxxbxx", "legacy test - got password fxxbxx");
ok($con_hash_t3{auth_type} eq "key", "legacy test - got auth_type pass for t3");

ok($con_hash_t4{user} eq "foo", "legacy test - got user foo for t4");
ok($con_hash_t4{password} eq "bar", "legacy test - got password bar for t4");
ok($con_hash_t4{auth_type} eq "key", "legacy test - got auth_type pass for t4");

ok($con_hash_t5{user} eq "foo", "legacy test - got user foo for t5 - overriding from ssh_config");
ok($con_hash_t5{password} eq "bar", "legacy test - got password bar for t5");
ok($con_hash_t5{auth_type} eq "key", "legacy test - got auth_type pass for t5");
ok($con_hash_t5{private_key} eq "~/.ssh/id_rsa_foo", "legacy test - got private_key for t5");

1;
