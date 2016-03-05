package TestsFor::Alpha::Subclass;

use Test::Class::Moose extends => 'TestsFor::Alpha', bare => 1;

use Test2::Tools::Basic qw( ok );
use Test2::Tools::Compare qw( array call end event is T );

sub test_another {
    ok 1;
}

sub expected_test_events {
    event Subtest => sub {
        call name      => 'TestsFor::Alpha::Subclass';
        call pass      => T();
        call subevents => array {
            event '+Test2::AsyncSubtest::Event::Attach';
            event Plan => sub {
                call max => 3;
            };
            event Subtest => sub {
                call name      => 'test_alpha_first';
                call pass      => T();
                call subevents => array {
                    event Ok => sub {
                        call name => undef;
                        call pass => T();
                    };
                    event Ok => sub {
                        call name => undef;
                        call pass => T();
                    };
                    event Plan => sub {
                        call max => 2;
                    };
                    end();
                };
            };
            event Subtest => sub {
                call name      => 'test_another';
                call pass      => T();
                call subevents => array {
                    event Ok => sub {
                        call name => undef;
                        call pass => T();
                    };
                    event Plan => sub {
                        call max => 1;
                    };
                    end();
                };
            };
            event Subtest => sub {
                call name      => 'test_second';
                call pass      => T();
                call subevents => array {
                    event Ok => sub {
                        call name => 'make sure plans work';
                        call pass => T();
                    };
                    event Plan => sub {
                        call max => 1;
                    };
                    end();
                };
            };
            event '+Test2::AsyncSubtest::Event::Detach';
            end();
        };
    };
}

1;
