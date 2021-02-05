let socket = new WebSocket("wss://irc-ws.chat.twitch.tv:443");

const queryParams = new URLSearchParams(window.location.search)
const channelToMonitor = queryParams.has("channel") ? queryParams.get("channel") : "straybasilisk";

let challengingPlayer;

socket.onopen = function(e) {
  console.log("[open] Connection established");
  socket.send("NICK justinfan42");
  socket.send("PASS SCHMOOPIIE");
  socket.send(`JOIN #${channelToMonitor}`);
};

socket.onmessage = function(event) {
  console.log(`[message] Data received from server: ${event.data}`);
  if (event.data == "PING :tmi.twitch.tv") {
      socket.send("PONG :tmi.twitch.tv");
      return;
  }

  // Chat message format:
  // :username!username@username.tmi.twitch.tv PRIVMSG #channel :content goes here
  let pieces = event.data.split(' ');
  if (pieces.length < 4) return;
  if (pieces[1] != "PRIVMSG") return;

  let username = pieces[0].split('!')[0].substring(1);
  let channelName = pieces[2].substring(1);
  let messageBody = pieces.slice(3).join(' ').substring(1).trim();
  let isAdmin = username.toLowerCase() == channelName.toLowerCase();
  
  console.log(`${metaState} // ${username} says: '${messageBody}'`);

  if (isAdmin) {
      if (messageBody == "!chessreset") {
        metaState = "idle";
        persistState();
        return;
      }
  }

  if (metaState == "idle" || metaState == "win" || metaState == "draw") {
    if (messageBody == "!chess") {
      challengingPlayer = username;
      metaState = "wait_accept";
      console.log(`${username} wants to play!`);
      persistState();
    }
  }
  else if (metaState == "wait_accept") {
    if (messageBody == "!chess" && (username != challengingPlayer || isAdmin)) {
      // Coin toss
      console.log(`${username} accepted the challenge!`);
      if (Math.random() < 0.5) {
        gameState = createGame(challengingPlayer, username);
      }
      else {
        gameState = createGame(username, challengingPlayer);
      }
      metaState = "playing";
      persistState();
    }
  }
  else if (metaState == "playing") {
    if (messageBody == "!concede")  {
        concede(username, isAdmin);
        persistState();
    }
    else {
        tryMakeMove(username, isAdmin, messageBody);
    }
  }
};

socket.onclose = function(event) {
  if (event.wasClean) {
    console.log(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);
  } else {
    // e.g. server process killed or network down
    // event.code is usually 1006 in this case
    console.log('[close] Connection died');
  }
};

socket.onerror = function(error) {
    console.log(`[error] ${error.message}`);
};