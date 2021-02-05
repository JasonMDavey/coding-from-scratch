const GRID_SIZE = 50;
const LIGHT_COLOR = "#eee3d4";
const DARK_COLOR = "#8537d1";
const MOVE_TRANSITION_MILLIS = 500.0;

const pieceImages = {};

let transitionElapsedMillis = 0;

/*
 * Pre-load assets
 */
function preload() {
	// Load piece image assets
	let pieceNames = ["pawn","king","queen","bishop","rook","knight"];
	for (let name of pieceNames) {
		pieceImages[name] = loadImage(`/img/${name}.png`);
		pieceImages[name+"_dark"] = loadImage(`/img/${name}_dark.png`);
	}
}

/*
 * Draw an empty chess board
 */
function drawBoard() {
	rectMode(CENTER);
	noStroke();
	
	fill(LIGHT_COLOR);
	rect(4*GRID_SIZE, 4*GRID_SIZE, 8*GRID_SIZE, 8*GRID_SIZE);
	
	fill(DARK_COLOR);
	
	for (let rank=0; rank<8; ++rank) {
		for (let file=0; file<8; ++file) {
			if (isDarkSquare(file, rank)) {
				let screenPos = getGridScreenPosition(file, rank);
				rect(screenPos.x, screenPos.y, GRID_SIZE, GRID_SIZE);
			}
		}
	}
	
	fill(0,255,0,128);
	for (let debugMove of debugMoves) {
		let screenPos = getGridScreenPosition(debugMove.file, debugMove.rank);
		rect(screenPos.x, screenPos.y, GRID_SIZE, GRID_SIZE);
	}
	noFill();
	stroke(0,255,0,128);
	strokeWeight(10);
	if (debugPiecePos != null) {
		let screenPos = getGridScreenPosition(debugPiecePos.file, debugPiecePos.rank);
		rect(screenPos.x, screenPos.y, GRID_SIZE, GRID_SIZE);
	}
}

function onMoveMade() {
	transitionElapsedMillis = 0;
}

/*
 * Draw all pieces on the board
 */
function drawPieces(gameState) {
	transitionElapsedMillis += deltaTime;

	imageMode(CENTER);
	
	for (let rank=0; rank<8; ++rank) {
		for (let file=0; file<8; ++file) {
			let piece = gameState.board[file][rank];
			if (piece == null) continue;
			
			// Highlight king when in check
			if (piece.type == "king" && isKingInCheck(gameState, piece.color))  {
				let screenPos = getGridScreenPosition(file, rank);
				noFill();
				stroke(255,0,0,128);
				strokeWeight(10);
				rect(screenPos.x, screenPos.y, GRID_SIZE, GRID_SIZE);
			}

			if (gameState.lastMoveTo && gameState.lastMoveTo.rank == rank && gameState.lastMoveTo.file == file) {
				// This piece just moved
				let transitionRatio = Math.min(transitionElapsedMillis / MOVE_TRANSITION_MILLIS, 1);
				let renderAtFile = lerp(gameState.lastMoveFrom.file, file, transitionRatio);
				let renderAtRank = lerp(gameState.lastMoveFrom.rank, rank, transitionRatio);
				drawPiece(piece.type, piece.color, renderAtFile, renderAtRank);
			}
			else {
				drawPiece(piece.type, piece.color, file, rank);
			}
			
		}
	}
}

function drawPiece(type, color, file, rank) {
	let imageName = type + (color === "dark" ? "_dark" : "");
	let screenPos = getGridScreenPosition(file, rank);

	image(pieceImages[imageName], screenPos.x, screenPos.y);	
}

/*
 * Draws UI
 */
function drawUI(gameState) {
	noStroke();
	
	textSize(20);
	textAlign(LEFT, BOTTOM);
	
	let playerIndex = 0;
	for (let playerColor of ["dark","light"]) {
		// Draw name label
		if (gameState.activeTurn === playerColor) { tint(255); fill(0); } else { tint(255,255,255,80); fill(200); }
		drawPiece("king",playerColor,0,-(playerIndex+1));
		text(gameState.playerNames[playerColor], GRID_SIZE*1, GRID_SIZE*(playerIndex+9)-10);
		tint(255);
		
		// Draw captured pieces
		let otherColor = getOppositeColor(playerColor);
		let capturedPieceIndex = 0;
		for (let capturedPiece of gameState.capturedPiecesOfColor[otherColor]) {
			drawPiece(capturedPiece, otherColor, 7-(capturedPieceIndex*0.3), -(playerIndex+1));
			++capturedPieceIndex;
		}
		
		++playerIndex;
	}
}

/*
 * Helper functions
 */

// Convert rank/file coordinates to canvas pixel positions
function getGridScreenPosition(file, rank) {
	return {
		x: file*GRID_SIZE + GRID_SIZE*0.5,
		y: (8-rank)*GRID_SIZE - GRID_SIZE*0.5
	}
}

// Convert canvas pixel position to rank/file coordinates
function getBoardPosition(x,y) {
	return {
		file: Math.floor(x/GRID_SIZE),
		rank: (7-Math.floor(y/GRID_SIZE))
	}
}

// True if a square is dark, based on its coordinates
function isDarkSquare(file, rank) {
	return file%2 == rank%2;
}
