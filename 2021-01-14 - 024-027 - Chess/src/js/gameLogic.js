const pieceMoves = {};

// Define data about legal moves for each piece type
pieceMoves["knight"] = [
	[[1,2]],[[2,1]],[[-1,2]],[[-2,1]],
	[[1,-2]],[[2,-1]],[[-1,-2]],[[-2,-1]]
];

pieceMoves["bishop"] = [
	[[1,1],[2,2],[3,3],[4,4],[5,5],[6,6],[7,7]], // up-right
	[[1,-1],[2,-2],[3,-3],[4,-4],[5,-5],[6,-6],[7,-7]], // down-right
	[[-1,1],[-2,2],[-3,3],[-4,4],[-5,5],[-6,6],[-7,7]], // up-left
	[[-1,-1],[-2,-2],[-3,-3],[-4,-4],[-5,-5],[-6,-6],[-7,-7]] // down-left
];

pieceMoves["rook"] = [
	[[0,1],[0,2],[0,3],[0,4],[0,5],[0,6],[0,7]], // up
	[[0,-1],[0,-2],[0,-3],[0,-4],[0,-5],[0,-6],[0,-7]], // down
	[[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0]], // right
	[[-1,0],[-2,0],[-3,0],[-4,0],[-5,0],[-6,0],[-7,0]] // left
];

pieceMoves["queen"] = [];
for (let c of pieceMoves["bishop"]) { pieceMoves["queen"].push(c); }
for (let c of pieceMoves["rook"]) { pieceMoves["queen"].push(c); }

pieceMoves["king"] = [
	[[-1,1]],[[0,1]],[[1,1]],[[-1,0]],[[1,0]],[[-1,-1]],[[0,-1]],[[1,-1]]
];

/*
 * Creates a new game-state
 */
function createGame(lightPlayerName, darkPlayerName) {
	return {
		board: createBoard(),
		activeTurn: "light",
		playerNames: {
			light: lightPlayerName,
			dark: darkPlayerName
		},
		capturedPiecesOfColor: {
			light: [],
			dark: []
		},
		lastMoveFrom: null,
		lastMoveTo: null,
		alertMessage: null
	};
}

/*
 * Creates an 8x8 board, with pieces in their default positions
 */
function createBoard() {
	// Create empty 8x8 grid
	let board = [];
	for (let file=0; file<8; ++file) {
		board.push(new Array(8));
	}
	
	// Put pieces in default positions
	for (let combo of [{rank:0,color:"light"}, {rank:7,color:"dark"}]) {
		board[0][combo.rank] = {type:"rook", color:combo.color};
		board[1][combo.rank] = {type:"knight", color:combo.color};
		board[2][combo.rank] = {type:"bishop", color:combo.color};
		board[3][combo.rank] = {type:"queen", color:combo.color};
		board[4][combo.rank] = {type:"king", color:combo.color};
		board[5][combo.rank] = {type:"bishop", color:combo.color};
		board[6][combo.rank] = {type:"knight", color:combo.color};
		board[7][combo.rank] = {type:"rook", color:combo.color};
	}
	
	for (let file=0; file<8; ++file) {
	    board[file][1] = {type:"pawn",color:"light",hasMoved:false};
		board[file][6] = {type:"pawn",color:"dark",hasMoved:false};
	}
	
	return board;
}

function concede(username, isAdmin) {
	if (!isAdmin && username.toLowerCase() != gameState.playerNames[gameState.activeTurn].toLowerCase()) {
		console.log("Not player's turn: " + username);
		return false;
	}

	console.log(`${gameState.playerNames[gameState.activeTurn]} concedes!`);

	gameState.activeTurn = getOppositeColor(gameState.activeTurn);
	metaState = "win";
}

function tryMakeMove(username, isAdmin, command) {
	if (!isAdmin && username.toLowerCase() != gameState.playerNames[gameState.activeTurn].toLowerCase()) {
		console.log("Not player's turn: " + username);
		return false;
	}

	if (command.length >= 4) {
		let fromTile = parsePosition(command.substring(0,2));
		let toTile = parsePosition(command.substring(2,4));
		let promoteTo = command.length == 5 ? command.substring(4,5) : null;
		
		if (toTile.rank == 0 || toTile.rank == 7) {
			let piece = getPieceAt(gameState.board, fromTile.file, fromTile.rank);
			if (piece != null && piece.type == "pawn") {
				if (promoteTo == null) {
					// This looks like a pawn promotion - wait for another input character
					console.log("Expecting pawn promotion indicator (Q/R/B/K)");
					gameState.alertMessage = "Promotion indicator required\n(Q/R/B/K)";
					return false;
				}
				else if (["q","r","b","k"].indexOf(promoteTo) == -1) {
					console.log("Invalid pawn promotion indicator (expected Q/R/B/K)");
					gameState.alertMessage = "Promotion indicator required\n(Q/R/B/K)";
					return false;
				}
			}
		}
		
		makeMove(gameState, fromTile, toTile, promoteTo);
		debugMoves = [];
		debugPiecePos = null;
		return true;
	}
	else if (command.length == 3 && command[2]=="?") {
		let fromTile = parsePosition(command.substring(0,2));
		let piece = gameState.board[fromTile.file][fromTile.rank];
		if (piece != null) {
			debugMoves = getPseudoLegalMoves(gameState, piece, fromTile);
			debugPiecePos = fromTile;
			return true;
		}
	}

	return false;
}

/*
 * Makes the specified move (if it's legal)
 */
function makeMove(gameState, from, to, promoteTo) {
	let piece = gameState.board[from.file][from.rank];
	if (piece == null) {
		console.log("No piece to move!");
		return;
	}
	
	if (piece.color !== gameState.activeTurn) {
		console.log("Not this piece's turn");
		return;
	}
	
	console.log("Requested:");
	console.log(to);
	
	let legalMoves = getPseudoLegalMoves(gameState, piece, from);
	
	console.log("Legal:");
	console.log(legalMoves);
	
	let isLegal = false;
	let moveTag = null;
	for (let legalMove of legalMoves) {
		if (legalMove.file == to.file && legalMove.rank == to.rank) {
			isLegal = true;
			moveTag = legalMove.tag;
			break;
		}
	}
	
	if (!isLegal) {
		console.log("Illegal move");
		gameState.alertMessage = "Illegal move =(";
		return;
	}
	
	// Check if this puts us in check, and disallow it
	if (piece.type == "king") {
		if (wouldKingBeUnderAttackIfMoved(gameState, piece, to, from, to)) {
			console.log("Move leaves king in check");
			return;
		}
	}
	else {
		let ourKing = findKing(gameState.board, piece.color);
		if (wouldKingBeUnderAttackIfMoved(gameState, ourKing.piece, ourKing.position, from, to)) {
			console.log("Move leaves king in check");
			return;
		}
	}
	
	// Make the actual move!
	let capturedPiece = gameState.board[to.file][to.rank];
	if (capturedPiece != null) {
		gameState.capturedPiecesOfColor[capturedPiece.color].push(capturedPiece.type);
	}
	gameState.board[to.file][to.rank] = piece;
	gameState.board[from.file][from.rank] = null;
	
	// Special moves
	if (moveTag == "shortCastle") {
		// Short castle - move the rook!
		gameState.board[5][to.rank] = gameState.board[7][to.rank];
		gameState.board[5][to.rank].hasMoved = true;
		gameState.board[7][to.rank] = null;
	}
	else if (moveTag == "longCastle") {
		// Long castle - move the rook!
		gameState.board[3][to.rank] = gameState.board[0][to.rank];
		gameState.board[3][to.rank].hasMoved = true;
		gameState.board[0][to.rank] = null;
	}
	else if (moveTag == "enpassant") {
		gameState.capturedPiecesOfColor[getOppositeColor(piece.color)].push("pawn");
		gameState.board[to.file][from.rank] = null;
	}
	
	// Promote a pawn if we just reached the final rank
	if (piece.type == "pawn" && (to.rank == 0 || to.rank == 7)) {
		if (promoteTo == "q") { piece.type = "queen"; }
		else if (promoteTo == "r") { piece.type = "rook"; }
		else if (promoteTo == "k") { piece.type = "knight"; }
		else if (promoteTo == "b") { piece.type = "bishop"; }
	}
	
	let oppositeColor = getOppositeColor(gameState.activeTurn);

	piece.hasMoved = true;
	gameState.lastMoveFrom = from;
	gameState.lastMoveTo = to;
	gameState.activeTurn = getOppositeColor(gameState.activeTurn);
	gameState.alertMessage = null;

	if (isKingInCheck(gameState, oppositeColor)) {
		// Check for checkmate!
		if (isKingCheckmated(gameState, oppositeColor)) {
			console.log(oppositeColor + " king is checkmated!!");
			metaState = "win";
		}
		else {
			console.log(oppositeColor + " king in check!");
		}
	}

	if (isStalemated(gameState, oppositeColor)) {
		console.log(oppositeColor + " king is stalemated!!");
		metaState = "draw";
	}

	onMoveMade();
	persistState();
}

function persistState() {
	localStorage["metaState"] = metaState;
	localStorage["gameState"] = JSON.stringify(gameState);
}


/*
 * Returns a list of all legal moves for the specified piece.
 * Doesn't filter out moves which are illegal due to rules around putting yourself in check.
 */
function getPseudoLegalMoves(gameState, piece, position) {
	let board = gameState.board;
	
	let legalMoves = [];
	
	let chains;
	
	if (piece.type == "pawn") {
		chains = generatePawnMoves(gameState, board, piece, position);
	}
	else {
		chains = pieceMoves[piece.type];
	}
	
	if (piece.type == "king" && !piece.hasMoved) {
		if (!isKingUnderAttack(gameState, piece, position)) {  // Can't castle out of check
			chains = chains.concat(generateCastlingMoves(board, piece, position));
		}
	}
	
	for (let chain of chains) {	
		for (let offset of chain) {
			// Apply offset to piece's current position to determine actual target tile
			let file = position.file + offset[0];
			let rank = position.rank + offset[1];
			let tag = offset[2]; // Tag for castling and en-passant

			// Filter out positions which are off the board
			if (!isInBounds(file, rank)) break;

			// Look up any piece in the tile we're moving to
			let pieceInTargetPosition = board[file][rank];

			// Can't take our own piece	
			if (pieceInTargetPosition != null && pieceInTargetPosition.color == piece.color) break;

			legalMoves.push({file: file, rank: rank, tag: tag});
			
			// If we took something, don't continue this chain
			if (pieceInTargetPosition != null) break;
		}
	}
	
	return legalMoves;
}

function generatePawnMoves(gameState, board, piece, position) {
	let chains = [];
		
	// Pawns move "forwards" - determine what that means in terms of coordinates
	// (depends on color of piece)
	let forwardDirection = piece.color == "light" ? 1 : -1;

	// Moving forwards
	let forwardMoveChain = [];

	if (getPieceAt(board, position.file, position.rank+1*forwardDirection) == null) {
		// Move forwards one square
		forwardMoveChain.push([0,1*forwardDirection]);
		if (!piece.hasMoved && getPieceAt(board, position.file, position.rank+2*forwardDirection) == null) {
			// Move forwards two squares
			forwardMoveChain.push([0,2*forwardDirection]);
		}
	}
	chains.push(forwardMoveChain);

	// Capturing diagonally
	for (let fileOffset of [1,-1]) { // Right and left
		let captureRank = position.rank+forwardDirection;
		let captureFile = position.file+fileOffset;

		let pieceToCapture = getPieceAt(board, captureFile, captureRank);
		if (pieceToCapture != null && pieceToCapture.color !== piece.color) {
			chains.push([[fileOffset,1*forwardDirection]]);
		}	
	}

	// En-passant
	if (gameState.lastMoveTo != null && gameState.lastMoveTo.rank == position.rank // Piece moved into our rank
			&& abs(gameState.lastMoveTo.file-position.file) == 1                       // Piece moved into immediately adjacent file
			&& abs(gameState.lastMoveFrom.rank-gameState.lastMoveTo.rank) == 2         // Piece just moved 2 ranks
			&& getPieceAt(board, gameState.lastMoveTo.file, gameState.lastMoveTo.rank).type == "pawn" // Piece is a pawn
		 ) {
		// Last move was a pawn moving into en-passant-able position next to us
		// This also implies there is no piece in our target tile (or the enemy pawn would have moved through it)
		chains.push([[gameState.lastMoveTo.file-position.file, forwardDirection, "enpassant"]]);
	}
	
	return chains;
}

function generateCastlingMoves(board, king, position) {
	let chains = [];
	
	// TODO: account for castling out of / through check
	let shortSideRook = board[7][position.rank];
	if (shortSideRook != null && !shortSideRook.hasMoved && getPieceAt(board, 6, position.rank)==null && getPieceAt(board, 5, position.rank)==null) {
		// Check intermediary move - can't "move through" check when castling
		let intermediaryMove = {file:5, rank: position.rank};
		if (!wouldKingBeUnderAttackIfMoved(gameState, king, intermediaryMove, position, intermediaryMove)) {
			chains.push([[2,0,"shortCastle"]]);
		}
	}

	let longSideRook = board[0][position.rank];
	if (longSideRook != null && !longSideRook.hasMoved && getPieceAt(board, 1, position.rank)==null && getPieceAt(board, 2, position.rank)==null && getPieceAt(board, 3, position.rank)==null) {
		// Check intermediary move - can't "move through" check when castling
		let intermediaryMove = {file:3, rank: position.rank};
		if (!wouldKingBeUnderAttackIfMoved(gameState, king, intermediaryMove, position, intermediaryMove)) {
			chains.push([[-2,0,"longCastle"]]);
		}
		
	}
	
	return chains;
}

function wouldKingBeUnderAttackIfMoved(gameState, king, kingPosition, pieceMovingFrom, pieceMovingTo) {
	// Clone the game state and provisionally make the move
	let clonedGameState = gameState.clone();
	clonedGameState.board[pieceMovingTo.file][pieceMovingTo.rank] = clonedGameState.board[pieceMovingFrom.file][pieceMovingFrom.rank];
	clonedGameState.board[pieceMovingFrom.file][pieceMovingFrom.rank] = null;
	
	return isKingUnderAttack(clonedGameState, king, kingPosition);
}

function isKingUnderAttack(gameState, king, position) {
	let attackingColor = getOppositeColor(king.color);
		
	for (let rank=0; rank<8; ++rank) {
		for (let file=0; file<8; ++file) {
			let attackingPiece = getPieceAt(gameState.board, file, rank);
			if (attackingPiece == null) continue;
			if (attackingPiece.color != attackingColor) continue;
			if (attackingPiece.type == "king") continue; // Kings can't check other kings!
			
			let legalMovesForAttacker = getPseudoLegalMoves(gameState, attackingPiece, {file: file, rank: rank});
			for (let attackingMove of legalMovesForAttacker) {
				if (attackingMove.file == position.file && attackingMove.rank == position.rank) {
					// Opponent's piece can move onto our tile, so we're under attack!
					return true;
				}
			}
		}
	}
	
	return false;
}

function findKing(board, color) {
	for (let rank=0; rank<8; ++rank) {
		for (let file=0; file<8; ++file) {
			let piece = getPieceAt(board, file, rank);
			if (piece != null && piece.color == color && piece.type == "king") {
				return {piece:piece, position:{file:file, rank:rank}};
			}
		}
	}
	return null;
}

function isKingInCheck(gameState, color) {
	let king = findKing(gameState.board, color);
	return isKingUnderAttack(gameState, king.piece, king.position);
}

function isKingCheckmated(gameState, color) {
	let king = findKing(gameState.board, color);
	
	for (let move of getPseudoLegalMoves(gameState, king.piece, king.position)) {
		if (!wouldKingBeUnderAttackIfMoved(gameState, king.piece, move, king.position, move)) {
			return false;
		}
	}

	// King has no moves which don't leave them in check!
	return true;
}

function isStalemated(gameState, color) {
	let king = findKing(gameState.board, color);

	for (let rank=0; rank<8; ++rank) {
		for (let file=0; file<8; ++file) {
			let piece = getPieceAt(gameState.board, file, rank);
			if (piece == null || piece.color != color) continue;

			let position = {file: file, rank: rank};
			for (let move of getPseudoLegalMoves(gameState, piece, position)) {
				if (piece.type == "king") {
					if (!wouldKingBeUnderAttackIfMoved(gameState, king.piece, move, king.position, move)) {
						return false;
					}
				}
				else {
					if (!wouldKingBeUnderAttackIfMoved(gameState, king.piece, king.position, position, move)) {
						return false;
					}
				}
			}
		}
	}

	// No piece has any moves which don't leave the king in check
	return true;
}

// Thank you xxMrPHDxx!!!
Object.prototype.clone = function(){
	return (typeof this[Symbol.iterator] === 'undefined')?
		Object.entries(this).reduce((obj,[k,v])=>{
		obj[k] = v===null?null:(typeof v==='object'?v.clone():v);
		return obj;
		},{}):this.map(a=>a===null?null:typeof a==='object'?a.clone():a);
};


/*
 * Helper functions
 */

// Returns the piece at the specified position on the board (if any)
function getPieceAt(board, file, rank) {
	return isInBounds(file, rank) ? board[file][rank] : null;
}
	
// True if the specified position is within the bounds of the board
function isInBounds(file, rank) {
	return file>=0 && file<8 && rank>=0 && rank<8;
}

function getOppositeColor(c) {
	return c==="light" ? "dark" : "light";
}