package APIProducer::Consumer;

=head1 NAME

APIProducer::Consumer - Interaction with api_producer sites

=head1 SYNOPSIS

  use APIProducer::Consumer;
  my $consumer = APIProducer::Consumer->new('base_uri' => 'http://foo/');
  $data = $consumer->make_request('/v1/w/foo',
    'json' => { 'foo' => 'bar' });

=head1 DESCRIPTION

This module is used to interact with api_producer sites.

Unless otherwise specified, methods return undef on failure.
The error message can be retrieved via the object's get_message() method.

=cut

use Moose;
use namespace::autoclean;

##
## Modules
##

use JSON::DWIW;
use LWP::UserAgent;
use URI::Escape;

##
## Variables
##

my $VERSION = '0.02';

=head1 OPTIONS

=over 4

=item base_uri

The base_uri. Default is http://localhost/api/.

=back

=cut

my $JSON;
my %OUTPUT = (
	'message' => '',
	'request' => undef,
	'response' => undef,
	'status' => 500,
);

has 'base_uri' => ('is' => 'rw', 'isa' => 'Str',
	'default' => 'http://localhost/api/');
has 'http_request' => ('is' => 'ro', 'isa' => 'Str', required => 1,
	'default' => 'HTTP::Request');
has 'json' => ('is' => 'ro', 'isa' => 'Object', required => 1,
	'default' => sub { JSON::DWIW->new() });
has 'ua' => ('is' => 'ro', 'isa' => 'Object', required => 1,
	'default' => sub { LWP::UserAgent->new() });

##
## Subroutines
##

=head1 METHODS

=over 4

=cut

#
# Public
#

sub get_message {

=item get_message

Return the message from the most recent API call.

=cut

	my $self = shift;
	return $self->_get('message');
}

sub get_request {

=item get_request

Return the HTTP::Request object from the most recent API call.

=cut

	my $self = shift;
	return $self->_get('request');
}

sub get_response {

=item get_response

Return the HTTP::Response object from the most recent API call.

=cut

	my $self = shift;
	return $self->_get('response');
}

sub get_status {

=item get_status

Return the status (if any) from the most recent function call.

=cut

	my $self = shift;
	return $self->_get('status');
}

sub get_details {

=item get_details

See make_request() for usage. Wrapper around make_request() to return
the details field.

=cut

	my $self = shift;

	my $output = $self->make_request(@_);
	if(defined($output)) {
		if(exists($output->{'details'})) {
			return $output->{'details'};
		}

		return $self->_set($output->{'status'},
			'API did not return details field');
	}

	return $output;
}

sub get_records {

=item get_records

See make_request() for usage. Wrapper around make_request() to return
the records field.

=cut

	my $self = shift;

	my $output = $self->make_request(@_);
	if(defined($output)) {
		if(exists($output->{'records'})) {
			return $output->{'records'};
		}

		return $self->_set($output->{'status'},
			'API did not return records field');
	}

	return $output;
}

sub make_request {

=item make_request($path, %options)

Make a request to an API at $path. Returns a ref to the data.

Options:

 * get - hash of parameters to add to the query string
 * json - hash of data to be JSONized

=cut

	my ($self, $path, $opts) = @_;
	my $err;
	my $input;
	my $output;
	my @query;
	my $request;
	my $response;
	my $uri;

	$self->_reset();

	$path =~ s|^/||;

	$uri = $self->base_uri();
	$uri =~ s|/$||;
	$uri .= '/' . $path;

	if(defined($opts->{'get'})) {
		while(my ($key, $value) = each(%{$opts->{'get'}})) {
			push(@query, sprintf("%s=%s", $key,
				uri_escape_utf8($value)));
		}
	}

	push(@query, 'outputFormat=json', 'statusHeader=0');
	$uri .= '?' . join('&', @query);

	if(defined($opts->{'json'})) {
		($input, $err) = $self->json()->to_json($opts->{'json'});
		if(defined($err)) {
			return _set(400, $err);
		}

		$request = $self->http_request()->new('POST' => $uri);
		$request->header('Content-Type' => 'application/json');
		$request->content($input);
	} else {
		# TODO: support normal POST (urlencode)

		$request = $self->http_request()->new('GET' => $uri);
	}

	$response = $self->ua()->request($request);

	$OUTPUT{'request'} = $request;
	$OUTPUT{'response'} = $response;

	if(!$response->is_success()) {
		return $self->_set($response->code(), $response->status_line());
	}

	($output, $err) =
		$self->json()->from_json($response->decoded_content());
	if(defined($err)) {
		return $self->_set(500, $err);
	}

	if(defined($output->{'status'})) {
		if(substr($output->{'status'}, 0, 1) eq 2) {
			$self->_set($output->{'status'}, $output->{'message'});
			return $output;
		}

		return $self->_set($output->{'status'}, $output->{'message'});
	}

	return $self->_set(500, $response->decoded_content());
}

#
# Private
#

sub _get {

=item _get($field)

Return $field (e.g., 'message') from the most recent function call.

=cut

	my ($self, $field) = @_;

	if(exists($OUTPUT{$field})) {
		return $OUTPUT{$field};
	}

	return undef;
}

sub _reset {

=item _reset

Reset common variables (status, message, etc).

=cut

	my $self = shift;

	$OUTPUT{'message'} = '';
	$OUTPUT{'response'} = undef;
	$OUTPUT{'request'} = undef;
	$OUTPUT{'status'} = 500;
}

sub _set {

=item _set($status, $message)

Wrapper to set the status and message and then return undef.

=cut

	my ($self, $status, $message) = @_;

	$OUTPUT{'message'} = $message;
	$OUTPUT{'status'} = $status;

	return undef;
}

##
## Do not edit below this line
##

=back

=cut

__PACKAGE__->meta()->make_immutable();

1;
