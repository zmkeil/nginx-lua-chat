<!doctype html>
<html>
<head>
<script>
var ws = null;
var name = document.getElementByIf('name').value;
var url = 'ws://' + location.hostname +
		(location.port != "80" ? ':' + location.port : ''); 
function connect() {
  if (ws !== null) return log('already connected');
  ws = new WebSocket(url);
  ws.onopen = function () {
    log('connected');
  };
  ws.onerror = function (error) {
    log(error);
  };
  ws.onmessage = function (e) {
    log('recv: ' + e.data);
  };
  ws.onclose = function () {
    log('disconnected');
    ws = null;
  };
  return false;
}
function disconnect() {
  if (ws === null) return log('already disconnected');
  ws.close();
  return false;
}
function send() {
  if (ws === null) return log('please connect first');
  var text = document.getElementById('text').value;
  document.getElementById('text').value = "";
  log('send: ' + text);
  ws.send(text);
  return false;
}
function log(text) {
  var li = document.createElement('li');
  li.appendChild(document.createTextNode(text));
  document.getElementById('log').appendChild(li);
  return false;
}
</script>
</head>
<body>
	<input id="name" type="text">
	<button type="button" onclick="return connect()"> 
		Connect
	</button>
	<button type="button" onclick="return disconnect();">
		Disconnect
	</button>
  <form onsubmit="return send();">
    <input id="text" type="text">
    <button type="submit">Send</button>
  </form>
  <ol id="log"></ol>
</body>
</html>