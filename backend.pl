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
        shift->do( '
          CREATE TABLE stats (
            key TEXT PRIMARY KEY NOT NULL,
            count INTEGER,
            UNIQUE(key) ON CONFLICT REPLACE
          )
        ' );
        1;
    }
};

package main;

use Mojolicious::Lite;
use Mojo::JSON qw /decode_json encode_json/;

get '/' => sub {
    my $c = shift;
    $c->render( text => 'Please POST /stats.json' );
};

post '/stats.json' => sub {
    my $c    = shift;
    my $data = decode_json $c->param('json');

    foreach my $key ( keys %{$data} ) {
        my $count = $data->{$key};

        my @res = Model::Stats->select( 'where key=?', $key );
        if (@res) {
            $count += $res[0]->count;
        }

        Model::Stats->create(    # here goes schema-defined upsert logic
            key   => $key,
            count => $count
        );
    }
    $c->render( text => 'ok' );
};

get '/stats.json' => sub {
    my $c = shift;

    my @res;

    foreach ( @{ Model::Stats->select() } ) {
        push @res, { $_->key => $_->count };
    }
    $c->render( json => \@res );
};

app->start;
