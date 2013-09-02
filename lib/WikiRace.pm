package WikiRace;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->to('core#welcome');

	$r->post('/')->to('core#start');
	
	$r->get('/getPage/:wikiPage')->to('core#getPage');
	
	$r->get('/reset' => sub {
		my $self = shift;
		$self->session(expires => 1);
		$self->redirect_to('/');
	});
	
}

1;
