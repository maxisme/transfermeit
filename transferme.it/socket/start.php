***REMOVED***
require '/var/www/transferme.it/socket/vendor/autoload.php';

use Ratchet\Server\IoServer;
use Ratchet\WebSocket\WsServer;
use Ratchet\Http\HttpServer;
use Notify\Note;

$note = new Note();
$ws = new WsServer($note);
$ws->disableVersion(0); // old, bad, protocol version

$server = IoServer::factory(
	new HttpServer($ws),
	48341
);

//local socket for on curl requests to Ratchet socket
$context = new React\ZMQ\Context($server->loop);
$pull = $context->getSocket(ZMQ::SOCKET_PULL);
$pull->bind('tcp://127.0.0.1:47802');
$pull->on('message', array($note, 'onLocal'));

//check for users that have not been active in the last 15 seconds and close them.
$server->loop->addPeriodicTimer(15, function () use ($note) {
	foreach($note->clients as $client)
	{
		if(isset($client->activity) && isset($client->UUID)){
			$now = date("Y-m-d H:i:s");
			//+1 = 16 second for good cause
			$endTime = date("Y-m-d H:i:s", strtotime($client->activity . " +" . 16 . " seconds"));

			if (new DateTime($now) > new DateTime($endTime)){
				//send message to socket object to close client UUID
				$note->onLocal("close|".$client->UUID);
			***REMOVED***
		***REMOVED***
	***REMOVED***
***REMOVED***);

$server->run();