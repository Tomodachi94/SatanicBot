# Copyright 2014 Eli Foster

use warnings;
use strict;
use diagnostics;

package SatanicBot::Bot;
use base qw(Bot::BasicBot);
use Data::Random qw(:all);
use Weather::Underground;
#use Data::Dumper;
use SatanicBot::Wiki;
use SatanicBot::WikiButt;
use LWP::Simple;
use WWW::Mechanize;

#Use this subroutine definition for adding commands.
sub said{
    my ($self, $message) = @_;

    #quit command: no args
    if ($message->{body} eq '$quit'){
        if ($message->{who} eq 'SatanicSanta'){
            $self->say(
                channel => $message->{channel},
                body    => 'I don\'t love you anymore'
            );
            $self->shutdown();
        } else {
            $self->say(
                channel => $message->{channel},
                body    => "$message->{who}: Fuck you, bitch ass."
            );
        }
    }

    #abbrv command: 2 args required: <abbreviation> <mod name>
    my $msg = $message->{body};
    my @words = split(/\s/, $msg, 3);
    if ($words[0] eq '$abbrv'){
        if ($words[1] =~ m/.+/){
            $self->say(
                channel => $message->{channel},
                body    => "Abbreviating $words[2] as $words[1]"
            );

            SatanicBot::Wiki->login();
            SatanicBot::Wiki->edit_gmods(@words[1,2]);
            SatanicBot::Wiki->logout();

            $self->say(
                channel => $message->{channel},
                body    => 'Abbreviation and documentation probably added. Return values are fucked, which then fucks the message code.'
            );
            #if (!SatanicBot::Wiki->edit_gmods(@words[1,2])) {
            #    $self->say(
            #        channel => $message->{channel},
            #        body    => 'Could not proceed. Abbreviation and/or name already on the list.'
            #    );
            #}
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    if ($message->{body} eq '$spookyscaryskeletons'){
        my @random_words = rand_words(
            wordlist => 'info/spook.lines',
            min      => 10,
            max      => 20
        );

        $self->say(
            channel => $message->{channel},
            body    => @random_words
        );

        #my $dump = Data::Dumper->new([$random_words[0]]);
        #$self->say(
        #    channel => $message->{channel},
        #    body    => $dump
        #);
    }

    my $weathermsg = $message->{body};
    my @weatherwords = split(/\s/, $weathermsg, 2);
    if ($weatherwords[0] eq '$weather'){
        if ($weatherwords[1] =~ m/.+/){
            my $weather = Weather::Underground->new(
                place => $weatherwords[1]
        );

        my $stuff   = $weather->getweather();
        $self->say(
            channel => $message->{channel},
            body    => "$stuff->[0]->{conditions} || Temperature: $stuff->[0]->{fahrenheit} F || Humidity: $stuff->[0]->{humidity}% || Winds: $stuff->[0]->{wind_direction} at $stuff->[0]->{wind_milesperhour} mph || Last updated: $stuff->[0]->{updated}"
        );
    } else {
        $self->say(
            channel => $message->{channel},
            body    => 'Please provide the required arguments.'
        );
        }
    }

    #if the command does not work when the API gets enabled, do what you did with $abbrv
    my $uploadmsg = $message->{body};
    our @uploadwords = split(/\s/, $uploadmsg, 3);
    if ($uploadwords[0] eq '$upload'){
        if ($uploadwords[1] =~ m/.+/){
            if ($uploadwords[2] =~ m/.+/){
                #$self->say(
                #    channel => $message->{channel},
                #    body    => 'Sorry, $wgAllowCopyUploads is not enabled on the Wiki yet :('
                #);
                SatanicBot::WikiButt->login();
                SatanicBot::WikiButt->upload();
                SatanicBot::WikiButt->logout();

                $self->say(
                    channel => $message->{channel},
                    body    => "Uploaded $uploadwords[2] to the Wiki."
                );
            } else {
                $self->say(
                    channel => $message->{channel},
                    body    => 'Please provide the required arguments.'
                );
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide the required arguments.'
            );
        }
    }

    my $osrcmessage = $message->{body};
    my @osrcwords = split(/\s/, $osrcmessage, 2);
    if ($osrcwords[0] eq '$osrc'){
        my $url = "https://osrc.dfm.io/$osrcwords[1]";
        if (head($url)){
            $self->say(
                channel => $message->{channel},
                body    => $url
            );
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Does not exist.'
            );
        }
    }

    if ($message->{body} eq '$src'){
        $self->say(
            channel => $message->{channel},
            body    => 'https://github.com/satanicsanta/SatanicBot'
        );
    }

    my $contribmsg = $message->{body};
    my @contribwords = split(/\s/, $contribmsg, 2);
    if ($contribwords[0] eq '$contribs'){
        if ($contribwords[1] =~ m/.+/){

            my $www = WWW::Mechanize->new();
            my $stuff = $www->get("http://ftb.gamepedia.com/api.php?action=query&list=users&ususers=$contribwords[1]&usprop=editcount&format=json") or die "Unable to get url.\n";
            my $decode = $stuff->decoded_content();
            my @contribs = $decode =~ m{\"editcount\":(.*?)\}};

            if ($decode =~ m{\"missing\"}){
                $self->say(
                    channel => $message->{channel},
                    body    => 'Please enter a valid username.'
                );
            } elsif ($decode =~ m{\"invalid\"}) {
                $self->say(
                    channel => $message->{channel},
                    body    => 'Sorry, but IPs are not compatible.'
                );
            } else {
                if ($contribs[0] eq '1'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "$contribwords[1] has made $contribs[0] contribution to the wiki."
                    );
                } elsif ($contribwords[1] eq 'SatanicBot') {
                    $self->say(
                        channel => $message->{channel},
                        body    => "I have made $contribs[0] contributions to the wiki."
                    );
                } elsif ($contribwords[1] eq 'TheSatanicSanta'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "My amazing and everlasting god, lord, savior, master, daddy has made $contribs[0] contributions to the wiki. Isn't he wonderful?"
                    );
                } elsif ($contribwords[1] eq 'retep998'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "The hottest babe in the channel has made $contribs[0] contributions to the wiki."
                    );
                } elsif ($contribwords[1] eq 'PonyButt'){
                    $self->say(
                        channel => $message->{channel},
                        body    => "FUCK YOU BITCH ASS NIGGA IM BETTER THAN YOU IN EVERY WAY, MOTHERFUCK ($contribs[0] contributions)"
                    );
                } else {
                    $self->say(
                        channel => $message->{channel},
                        body    => "$contribwords[1] has made $contribs[0] contributions to the wiki."
                    );
                }
            }
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Please provide a username.'
            );
        }
    }

    if ($message->{body} eq '$8ball'){
        my $file = 'info/8ball.txt';
        open my $fh, '<', $file or die "Could not open '$file' $!\n";
        my @lines = <$fh>;
        close $fh;
        chomp @lines;
        my $num = int(rand(35));
        $self->say(
            channel => $message->{channel},
            body    => $lines[$num]
        );
    }

    if ($message->{body} eq '$flip'){
        my $coin = int(rand(2));
        if ($coin eq 1){
            $self->say(
                channel => $message->{channel},
                body    => 'Heads!'
            );
        } else {
            $self->say(
                channel => $message->{channel},
                body    => 'Tails!'
            );
        }
    }

    if ($message->{body} eq '$help'){
        $self->say(
            channel => $message->{channel},
            body    => 'Listing commands... quit, abbrv, spookyscaryskeletons, weather, upload, osrc, src, contribs, flip, 8ball'
        );
    }
}
1;
