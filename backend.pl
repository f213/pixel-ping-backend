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
    $c->render('index');
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

    foreach ( @{ Model::Stats->select('order by count desc') } ) {
        push @res, { $_->key => $_->count };
    }
    $c->render( json => \@res );
};

app->start;

__DATA__
@@ index.html.ep
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Pixel Ping backend</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-md-8">
                <h1>Pixel-ping stats</h1>
                <p>
                    <a href="https://documentcloud.github.io/pixel-ping/">
                    Pixel Ping</a> is a simple pixel-tracker.
                    To get stats pleas GET /stats.json.
                    To update stats POST /stats.json.
                </p>
                <table class="table table-condensed table-hover table-responsive table-striped">
                    <thead>
                        <tr>
                            <th>Key</th>
                            <th>Count</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script>
        $.ajax({
            url: '/stats.json',
        })
        .done(function(data){
            for (i in data){
                var key = Object.keys(data[i])[0];
                $('tbody').append(
                    "<tr><td>" + key + "</td><td>" + data[i][key]
                    + "</td></tr>"
                );
            }
        });
    </script>
</body>

