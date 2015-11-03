#!/usr/bin/env perl
#
# Copyright (c) 2015 Fedor Borshev <f@f213.in>. http://f213.in
#
# Usage: ./backend.pl
#

package Model;
use strict;
use ORLite {
    file   => 'stats.sqlite',
    create => sub {
        shift->do(
            'CREATE TABLE stats (
        count INTEGER,
        key TEXT NOT NULL
      )'
        );
        1;
    }
};

package main;

use Mojolicious::Lite;
use JSON::XS;

get '/' => sub {
    my $c = shift;
    $c->render( text => 'Please POST /stats.json' );
};

post '/stats.json' => sub {
    my $c    = shift;
    my $data = JSON::XS->new->decode( $c->param('json') );

    foreach my $key ( keys %{$data} ) {
        Model::Stats->create(
            key   => $key,
            count => $data->{$key}
        );
    }
    $c->render( text => 'ok' );
};

app->start;
