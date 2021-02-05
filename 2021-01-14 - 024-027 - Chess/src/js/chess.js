/*
 * Chess piece images are by Lucas312 (https://opengameart.org/content/pixel-chess-pieces)
 */

let metaState = "idle";

let gameState;
let debugPiecePos = null;
let debugMoves = [];

let testInput;

/*
 * Called at start of program
 */
function setup() {
	let canvas = createCanvas(GRID_SIZE*8, GRID_SIZE*(8+2));
	canvas.elt.oncontextmenu = e=>e.preventDefault();
	
	// Hacky testing code - displays an input box,
	// and triggers moves based on the input
	testInput = createInput("");
	testInput.size(50, 50);
	testInput.input(() => {
		if (tryMakeMove("", true, testInput.value())) {
			testInput.value("");
		}
	});

	console.log(localStorage);
	if (localStorage["metaState"]) {
		metaState = localStorage["metaState"];
		gameState = JSON.parse(localStorage["gameState"]);
	}
}

/*
 * Called every frame
 */
function draw() {
	background(255);
	drawBoard();

	fill(255);
	stroke(0);
	strokeWeight(8);
	textAlign(CENTER, CENTER);
	textSize(40);
		
	if (metaState == "idle") {
		text(`Say '!chess' to play!`, width/2, GRID_SIZE*4);
	}
	else if (metaState == "wait_accept") {
		text(`Say '!chess' to accept!`, width/2, GRID_SIZE*4);
	}
	else if (metaState == "playing") {
		drawPieces(gameState);
		drawUI(gameState);

		if (gameState.alertMessage) {
			fill(255);
			stroke(0);
			strokeWeight(8);
			textAlign(CENTER, CENTER);
			textSize(30);
			text(gameState.alertMessage, width/2, GRID_SIZE*4);
		}
	}
	else if (metaState == "win") {
		let winningSide = gameState.activeTurn;
		let winningPlayer = gameState.playerNames[winningSide];
		text(`${winningPlayer}\nwins!`, width/2, GRID_SIZE*4);
	}
	else if (metaState == "draw") {
		text(`It's a draw!`, width/2, GRID_SIZE*4);
	}
}


function parsePosition(positionString) {
	let file = positionString.charCodeAt(0) - "a".charCodeAt(0);
	let rank = positionString.charCodeAt(1) - "1".charCodeAt(0);
	return {file: file, rank: rank};
}
	
function mousePressed() {
	let boardPos = getBoardPosition(mouseX, mouseY);
	if (boardPos.file >= 0 && boardPos.file < 8
	 && boardPos.rank >= 0 && boardPos.rank < 8) {
		if (mouseButton === LEFT) {
			let fileChar = String.fromCharCode("a".charCodeAt(0) + boardPos.file);
			let rankChar = String.fromCharCode("1".charCodeAt(0) + boardPos.rank);
			testInput.value(testInput.value()+fileChar+rankChar);
			tryMakeMove("", true, testInput.value());
		}
		else if (mouseButton === RIGHT) {
			gameState.board[boardPos.file][boardPos.rank] = null;
		}
	}
}
