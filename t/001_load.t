use strict;
use warnings;
use Test::More tests => 18;
use HTTP::Request;
use Plack::Builder qw{builder enable};
use Plack::Test;
BEGIN { use_ok('Plack::Middleware::Favicon_Simple') };

{
  my $obj = Plack::Middleware::Favicon_Simple->new;
  can_ok($obj, 'call');
  can_ok($obj, 'favicon');
  isa_ok($obj, 'Plack::Middleware::Favicon_Simple');
  isa_ok($obj, 'Plack::Middleware');
  is($obj->favicon('foo'), 'foo', 'favicon');
}

{
  my $app  = builder {
       enable 'Plack::Middleware::Favicon_Simple';
       sub {return [ 200, [], ['OK']]};
     };
  my $test = Plack::Test->create($app);

  {
    my $res = $test->request(HTTP::Request->new(GET => '/'));
    ok($res->is_success, 'success');
    is($res->code, 200, 'http code');
    is($res->content, 'OK', 'content');
  }

  {
    my $obj = Plack::Middleware::Favicon_Simple->new;
    my $res = $test->request(HTTP::Request->new(GET => '/favicon.ico'));
    ok($res->is_success, 'success');
    is($res->code, 200, 'http code');
    is($res->content, $obj->favicon, 'content');
  }
}

{
  my $app  = builder {
       enable 'Plack::Middleware::Favicon_Simple', favicon => 'foo';
       sub {return [ 200, [], ['OK']]};
     };
  my $test = Plack::Test->create($app);
  {
    my $res = $test->request(HTTP::Request->new(GET => '/path_info'));
    ok($res->is_success, 'success');
    is($res->code, 200, 'http code');
    is($res->content, 'OK', 'content');
  }

  {
    my $res  = $test->request(HTTP::Request->new(GET => '/favicon.ico'));
    ok($res->is_success, 'success');
    is($res->code, 200, 'http code');
    is($res->content, 'foo', 'content');
  }
}
