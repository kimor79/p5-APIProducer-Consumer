package APIProducer::Consumer;

=head1 NAME

APIProducer::Consumer - Interaction with api_producer sites

=head1 SYNOPSIS

  use APIProducer::Consumer;
  my $consumer = APIProducer::Consumer->new('base_uri' => 'http://foo/');
  $data = $consumer->post('uri' => '/v1/w/foo', 'data' => { 'foo' => 'bar' });

=head1 DESCRIPTION

This module is used to interact with the api_producer sites.

Unless otherwise specified, methods return undef on failure.
The error string can be retrieved via the object's errstr() method.

=cut

use strict;
use warnings;

##
## Modules
##

use Hash::Merge;
use JSON::DWIW;
use LWP::UserAgent;
use URI::Escape;

##
## Variables
##

BEGIN {
	$APIProducer::Consumer::errstr = '';
}

my $VERSION = '0.01';

=head1 OPTIONS

=over 4

=item base_uri

The base_uri. Default is http://localhost/api/.

=item lwp_opts

Options to be passed on to LWP::UserAgent. E.g., ssl_opts and/or agent.

=back

=cut

my $JSON;
my $PARAMS = {
	'base_uri' => 'http://localhost/api/',
	'lwp_opts' => {
		'agent' => __PACKAGE__ . '/' . $VERSION,
	},
};

##
## Subroutines
##

=head1 METHODS

=over 4

=cut

#
# Public
#

sub errstr {

=item errstr

Return the error (if any) from the most recent function call.

=cut

	return $APIProducer::Consumer::errstr;
}

sub get {

=item get($path, %params)

GET to an API at $path. Returns a ref to the data.

=cut

	my ($self, $path, $params) = @_;
	my $err;
	my $output;
	my @query;
	my $request;
	my $response;
	my $url;

	$APIProducer::Consumer::errstr = '';

	$path =~ s|^/||;

	$url = $self->get_param('base_uri');
	$url =~ s|/$||;
	$url .= '/' . $path;

	while(my ($key, $value) = each(%{$params})) {
		push(@query, sprintf("%s=%s", $key, uri_escape_utf8($value)));
	}

	push(@query, 'outputFormat=json', 'restfulOutput=0');
	$url .= '?' . join('&', @query);

	$response = $self->{'ua'}->get($url);
	if(!$response->is_success()) {
		return _errstr($response->status_line());
	}

	($output, $err) = $JSON->from_json($response->decoded_content());
	if(defined($err)) {
		return _errstr($err);
	}

	if(defined($output->{'status'})) {
		if(substr($output->{'status'}, 0, 1) eq 2) {
			return $output;
		}

		return _errstr($output->{'message'});
	}

	return _errstr($response->decoded_content());
}

sub get_param {

=item get_param($param)

=item get_param($param, $sub)

Return the value of the given parameter. An optional sub item can be given
to return the value of a sub-section parameter.

=cut

	my ($self, $param, $sub) = @_;
	my $message = 'Unknown parameter: ' . $param;

	$APIProducer::Consumer::errstr = '';

	if(exists($PARAMS->{$param})) {
		if(defined($sub)) {
			if(exists($PARAMS->{$param}->{$sub})) {
				return $PARAMS->{$param}->{$sub};
			}

			$message .= ' - ' . $sub;
		} else {
			return $PARAMS->{$param};
		}
	}

	return _errstr($message);
}

sub new {

=item new(%options)

Create a new object. See OPTIONS for available options.

The LWP::UserAgent object can be access directly via this module's object,
e.g.: $consumer->{'ua'}

On failure, inspect $APIProducer::Consumer::errstr;

=cut

	my $proto = shift;
	my $options = {@_};
	my $class = ref($proto) || $proto;
	my $self = {};

	if(defined($options) && ref($options) eq 'HASH') {
		foreach my $param (keys(%{$PARAMS})) {
			if(exists($options->{$param})) {
				$PARAMS->{$param} = $options->{$param};
			}
		}
	}

	$JSON = JSON::DWIW->new();

	local $SIG{__WARN__} = sub { die $_[0]; };
	eval {
		$self->{'ua'} = LWP::UserAgent->new(%{$PARAMS->{'lwp_opts'}});
	};
	if($@) {
		$APIProducer::Consumer::errstr = $@;
		return undef;
	}

	return bless($self, $class);
}

sub post {

=item post($path, %options)

POST to an API at $path. Returns a ref to the data.

Required options:

 * data - e.g., { 'foo' => 'bar' }

Optional options:

 * get - hash of parameters to add to the query string

=cut

	my ($self, $path, $opts) = @_;
	my $err;
	my $input;
	my $output;
	my @query;
	my $request;
	my $response;
	my $url;

	$APIProducer::Consumer::errstr = '';

	$path =~ s|^/||;

	$url = $self->get_param('base_uri');
	$url =~ s|/$||;
	$url .= '/' . $path;

	if(defined($opts->{'get'})) {
		while(my ($key, $value) = each(%{$opts->{'get'}})) {
			push(@query, sprintf("%s=%s", $key,
				uri_escape_utf8($value)));
		}
	}

	push(@query, 'outputFormat=json', 'restfulOutput=0');
	$url .= '?' . join('&', @query);

	$request = HTTP::Request->new('POST' => $url);

	# TODO: support normal POST (urlencode)

	($input, $err) = $JSON->to_json($opts->{'data'});
	if(defined($err)) {
		return _errstr($err);
	}

	$request->header('Content-Type' => 'application/json');
	$request->content($input);

	$response = $self->{'ua'}->request($request);
	if(!$response->is_success()) {
		return _errstr($response->status_line());
	}

	($output, $err) = $JSON->from_json($response->decoded_content());
	if(defined($err)) {
		return _errstr($err);
	}

	if(defined($output->{'status'})) {
		if(substr($output->{'status'}, 0, 1) eq 2) {
			return $output;
		}

		return _errstr($output->{'message'});
	}

	return _errstr($response->decoded_content());
}

sub set_param {

=item set_param($param, $value)

=item set_param($param, $sub, $value)

Modify a parameter. Returns the newly set value.

=cut

	my ($self, $param, $sub, $value);

	$APIProducer::Consumer::errstr = '';

	if(scalar(@_) eq 3) {
		($self, $param, $value) = @_;
	} else {
		($self, $param, $sub, $value) = @_;
	}

	my $message = 'Unknown param: ' . $param;

	if(exists($PARAMS->{$param})) {
		if(defined($sub)) {
			if(exists($PARAMS->{$param}->{$sub})) {
				$PARAMS->{$param}->{$sub} = $value;
				return $self->get_param($param, $sub);
			}

			$message .= ' - ' . $sub;
		} else {
			$PARAMS->{$param} = $value;
			return $self->get_param($param);
		}
	}

	return _errstr($message);
}

#
# Private
#

sub _errstr {
# Purpose:: set error string and return undef;

	$APIProducer::Consumer::errstr = shift;
	return undef;
}

##
## Do not edit below this line
##

=back
=cut
1;
