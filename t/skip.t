#!/usr/bin/env perl

use lib 'lib', 't/lib';

use Test2::API qw( intercept );
use Test2::Tools::Basic qw( done_testing fail ok pass );
use Test2::Tools::Compare qw( array call end event F is match T );
use Test::Events;

use Test::Class::Moose::Load qw(t/skiplib);
use Test::Class::Moose::Runner;

my $runner = Test::Class::Moose::Runner->new;

test_events_is(
    intercept { $runner->runtests },
    array {
        event Plan => sub {
            call max => 2;
        };
        TestsFor::SkipAll->expected_test_events;
        TestsFor::SkipSomeMethods->expected_test_events;
        end();
    },
    'got expected events for skip tests'
);

my $classes = $runner->test_report->test_classes;

{
    is $classes->[0]->name, 'TestsFor::SkipAll',
      'Our first class should be listed in reporting';

    my $instances = $classes->[0]->test_instances;

    ok $instances->[0]->is_skipped, '... and it should be listed as skipped';
    ok $instances->[0]->passed,     '... and it is reported as passed';
}

{
    is $classes->[1]->name, 'TestsFor::SkipSomeMethods',
      'Our second class should be listed in reporting';

    my $instances = $classes->[1]->test_instances;
    ok !$instances->[0]->is_skipped,
      '... and it should NOT be listed as skipped';
    ok $instances->[0]->passed, '... and it is reported as passed';
    my $methods = $instances->[0]->test_methods;

    is @$methods, 3, '... and it should have three test methods';

    my @skipped = grep { $_->is_skipped } @$methods;
    is scalar @skipped, 1,
      '... and the correct number of methods should be skipped';
    is $skipped[0]->name, 'test_me',
      '... and they should be the correct methods';
    is $skipped[0]->num_tests_run, 0,
      '... and we should have 0 tests run';
}

done_testing;
