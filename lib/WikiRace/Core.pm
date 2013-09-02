package WikiRace::Core;
use lib '..';
use Helper;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Mojo::Log;
use Mojo::UserAgent;
my $ua = Mojo::UserAgent->new;




sub welcome {
	my $self = shift;
	$self->render();
}

sub start {
        my $self = shift;
        my $pages = $wiki->api({
                action          => 'query',
                list            => 'random',
                rnnamespace     => '0',
                rnlimit         => '2' });
        my $start       = $pages->{query}->{random}->[0]->{'title'};
        my $finish      = $pages->{query}->{random}->[1]->{'title'};
        $self->session( start => $start );
        $self->session( finish => $finish );
        my $finish_title = $finish;
        $finish_title =~ s/\s/_/g;
	my $start_title = $start; 
	$start_title =~ s/\s/_/g;
        my $page = $ua->get("http://en.wikipedia.org/wiki/$finish_title");
        my $wiki_data = $page->res->dom->at('div#content.mw-body')->all_text;
	
        $self->render(wiki_data => $wiki_data, start => $start, finish => $finish, start_title => $start_title);


}


sub getPage {
	my $self = shift;
	my $count = $self->session('count') ||"0";
	my $start = $self->session('start');
	my $finish = $self->session('finish');
	my $page_title = $self->param('wikiPage');
	if($page_title =~ /$finish/) {
                $self->render(count => $count, template => 'core/victory');
        } else {
		$log->debug("Starting get");
		my $page = $ua->get("http://en.wikipedia.org/wiki/$page_title")->res->dom;
		$log->debug("Starting Parse");
		my $wiki_data = $page->at('div#content.mw-body');
		$log->debug("Starting replace");
		$wiki_data =~ s/\/wiki\//\/getPage\//g;
		$wiki_data =~ s/Jump to:.*//g;
		#$wiki_data =~ s/.*\/w\/.*//g;
		$log->debug("out of replace");
		$count++;
		$self->session( count => $count);
		$self->render(wiki_data => $wiki_data, count => $count);
	}
}

1;
