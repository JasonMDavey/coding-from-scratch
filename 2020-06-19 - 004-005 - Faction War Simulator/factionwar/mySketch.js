let backgroundImage;
let iconStrong;
let debugDraw = false;

let INFLUENCE_DECAY_RATE = 0.2;
let REBELLION_INFLUENCE_THRESHOLD = 5;
let REBELLION_PROBABILITY = 0.005;

let CONQUERING_FACTION_BONUS = 25;

// The range of influcence each virtual "player" in a faction generates per tick
let PLAYER_MIN_INFLUENCE = 0.01;
let PLAYER_MAX_INFLUENCE = 0.03;

let BAR_WIDTH = 30;
let BAR_HEIGHT = 6;

let graphPoints = [];
let graphInterval = 1;
let graphCounter = 0;

/*
 * Pre-load assets
 */
function preload() {
	// Load the background map and all of the territory images
  backgroundImage = loadImage('background.png');
  for (let i=0; i<=22; ++i) {
    let filename = `Layer ${i}.png`;
		territories[i].image = loadImage(filename);
  }
	
	iconStrong = loadImage('icon-strong.png');
}


/*
 * Initialise drawing canvas and map state
 */
function setup() {
  createCanvas(backgroundImage.width, backgroundImage.height);
	
	// Init faction influence
	for (let t in territories) {
		let territory = territories[t];
		territory.influence = {};
		for (let name in factions) {
			territory.influence[name] = 0;
		}
	}
	
	// Make sure each faction owns, and has max influence, in their home location
	for (let name in factions) {
		let faction = factions[name];
		
		faction.score = 0;
		
		if (faction.home != null) {
			territories[faction.home].owner = faction;
			territories[faction.home].influence[name] = 100;
		}
	}
}


/*
 * Called once per frame
 */
function draw() {
	/*
	 * Update
	 */
	for (let i=0; i<10; ++i) {
		simulate();
	}
	
	/*
	 * Draw
	 */
	
	// Draw background (map) image
	imageMode(CORNER);
	tint(255,255,255);
  image(backgroundImage, 0, 0);
  
	// Draw each territory in the colour of its owner
  for (let t in territories) {
		let territory = territories[t];
		
		if (territory.owner != null) {
			tint(territory.owner.color.r, territory.owner.color.g, territory.owner.color.b, 200);
			imageMode(CENTER);
			image(territory.image, territory.center.x, territory.center.y);
		}
		
		if (territory.power > 1) {
			tint(255,255,255,255);
			imageMode(CENTER);
			image(iconStrong, territory.center.x-32, territory.center.y);
		}
  }
	
	// Score graph
	let graphLeft = 450;
	let graphTop = 400;
	let graphHeight = height-graphTop;
	let graphWidth = width-graphLeft
	fill(0);
	rect(graphLeft, graphTop, graphWidth, graphHeight);
	
	let maxGraphValue = 0;
	for (let entry of graphPoints) {
		for (let faction in entry) {
			maxGraphValue = max(entry[faction], maxGraphValue);
		}
	}
	
	let textYCursor = graphTop + 20;
	
	for (let factionName in factions) {
		let faction = factions[factionName];
		
		// Score label
		fill(faction.color.r, faction.color.g, faction.color.b);
		noStroke();
		text(`${factionName}: ${faction.score}`, graphLeft + 10, textYCursor);
		textYCursor += 20;
			
		// Graph
		noFill();
		stroke(faction.color.r, faction.color.g, faction.color.b);
		beginShape();
		for (let i in graphPoints) {
			let val = graphPoints[i][factionName];
			let x = graphLeft + (graphWidth * i / graphPoints.length);
			let y = height - (graphHeight * val / maxGraphValue);
			vertex(x,y);
		}
		endShape();
	}
	
	// Toggle-able debug overlay
	if (debugDraw) {
		for (let t in territories) {
			let territory = territories[t];
			
			// Draw bars to show faction influence
			let yCursor = -BAR_HEIGHT;
			for (let factionName in territory.influence) {
				let faction = factions[factionName];
				
				// Draw backing / border
				stroke(0);
				fill(0);
				rect(territory.center.x-(BAR_WIDTH/2), territory.center.y + yCursor, BAR_WIDTH, BAR_HEIGHT);
				
				// Draw fill, based on faction's influence
				noStroke();
				fill(faction.color.r, faction.color.g, faction.color.b);
				rect(territory.center.x-(BAR_WIDTH/2), territory.center.y + yCursor, territory.influence[factionName]*BAR_WIDTH/100, BAR_HEIGHT);
				
				// Next bar should be drawn lower down
				yCursor += BAR_HEIGHT+4;
			}
		}
	}
}


/*
 * Simulate faction expansion etc
 */
function simulate() {
	
	// Invasion!
	if (random(0,1)<0.0003) {
		applyInfluence(territories[5], "Paulus autem Nicaenum", 999);
		applyInfluence(territories[5], "Paulus autem Nicaenum", 999);
		console.log("PAUL!");
	}
	
	// Respawn
	for (let factionName in factions) {
		let faction = factions[factionName];
		if (faction.home != null && territories[faction.home].owner != faction && random(0,1)<0.0003) {
			applyInfluence(territories[faction.home], factionName, 999);
			applyInfluence(territories[faction.home], factionName, 999);
		}
	}
	
	/*
	 * Decay and rebellion
	 */
	for (let t in territories) {
		let territory = territories[t];
		if (territory.owner == null) continue;
		if (territory.owner.home == t) continue; // No decay in home territory
		
		for (let factionName in factions) {
			// Decay influence a bit
			let newInfluence = max(0, territory.influence[factionName] - INFLUENCE_DECAY_RATE);
			territory.influence[factionName] = newInfluence;

			// When a faction has low influence in a piece of their territory, there is a chance of rebellion
			if (factionName == territory.owner.name && newInfluence < REBELLION_INFLUENCE_THRESHOLD && random(0,1)<REBELLION_PROBABILITY) {
				// Owner loses territory
				for (let f in territory.influence) {
					territory.influence[f] = 0;
				}
				territory.owner = null;
				break;
			}
		}
	}
	
	// Factions gain influence
	evenSpreadAndUpkeepStrat("church", 0, 0);
	evenSpreadAndUpkeepStrat("industrialists", 0.05, 20);
	evenSpreadAndUpkeepStrat("jasonstansfigulusluti", 0, 0);
	evenSpreadAndUpkeepStrat("Andrew et Barbatus scripsit", 0.05, 50);
	evenSpreadAndUpkeepStrat("Paulus autem Nicaenum", 0, 0);
	
	// Scoring
	for (let t in territories) {
		let territory = territories[t];
		if (territory.owner != null) {
			++territory.owner.score;
		}
	}
	
	++graphCounter;
	
	if (graphCounter % graphInterval == 0) {
		let graphPoint = {};
		for (let factionName in factions) {
			graphPoint[factionName] = factions[factionName].score;
		}
		graphPoints.push(graphPoint);

		if (graphPoints.length == 1000) {
			// Crunch down the graph to half-resolution
			let oldGraph = graphPoints;
			graphPoints = [];
			for (let i=0; i<oldGraph.length; i+=2) {
				graphPoints.push(oldGraph[i]);
			}

			graphInterval *= 2;
		}
	}
}


/*
 * Simple strategy for applying influence:
 * - Evenly divide our influence across all territories along our border, which we do not yet own
 */
function evenSpreadAndUpkeepStrat(factionName, upkeepRatio, upkeepInfluenceThreshold) {
	let faction = factions[factionName];
	
	// Figure out which territories are neighbours of territories we already own
	let territoriesToExpandInto = [];
	
	for (let t in territories) {
		let territory = territories[t];
		if (territory.owner != faction) continue;
		
		for (let n of territory.neighbours) {
			let neighbour = territories[n];
			if (neighbour.owner == faction) continue;
			
			//if (neighbour.owner != null && neighbour.owner.home == n) continue;
			
			if (!territoriesToExpandInto.includes(neighbour)) {
				territoriesToExpandInto.push(neighbour);
			}
		}
	}
	
	// Figure out territories for upkeep
	let territoriesForUpkeep = [];
	
	for (let t in territories) {
		let territory = territories[t];
		if (territory.owner != faction) continue;
		
		if (territory.influence[factionName] < upkeepInfluenceThreshold) {
			territoriesForUpkeep.push(territory);
		}
	}
	
	if (territoriesToExpandInto.length == 0 && territoriesForUpkeep == 0) return;
	
	let expandRatio = 1.0 - upkeepRatio;
	
	if (territoriesToExpandInto.length == 0) {
		expandRatio = 0;
		upkeepRatio = 1;
	}
	else if (territoriesForUpkeep.length == 0) {
		expandRatio = 1;
		upkeepRatio = 0;
	}
	
	// Apply influence
	let totalInfluenceGain = calculateTotalInfluenceThisTick(faction);
	
	if (expandRatio > 0) {
		let influenceGainPerTerritory = expandRatio * totalInfluenceGain / territoriesToExpandInto.length;
		for (let t of territoriesToExpandInto) {
			applyInfluence(t, factionName, influenceGainPerTerritory / t.power);
		}
	}
	
	if (upkeepRatio > 0) {
		let influenceGainPerTerritory = upkeepRatio * totalInfluenceGain / territoriesForUpkeep.length;
		for (let t of territoriesForUpkeep) {
			applyInfluence(t, factionName, influenceGainPerTerritory);
		}
	}
}


/*
 * Influence generated by each faction depends on the number of players in the faction, with some randomness
 */
function calculateTotalInfluenceThisTick(faction) {
	return faction.players * random(PLAYER_MIN_INFLUENCE, PLAYER_MAX_INFLUENCE);
}


/*
 * Apply a certain amount of influence ot a territory.
 * Handles the situation when a faction gains ownership of a territory
 */
function applyInfluence(territory, factionName, amount) {
	// When a faction hits max influence over a territory, two things can happen:
	// If nobody owns the territory, the faction becomes the new owner
	// If somebody else owns the territory then it becomes un-owned, and factions begin racing to become the new owner	
	let newInfluence = territory.influence[factionName] + amount;
	
	if (newInfluence >= 100 && territory.owner != factions[factionName]) {
		// Faction changes hands...
		
		for (let f in territory.influence) {
			territory.influence[f] = 0;
		}
		
		if (territory.owner == null) {
			// We now own this territory!
			territory.owner = factions[factionName];
			territory.influence[factionName] = 100;
		}
		else {
			// Faction becomes neutral
			territory.owner = null;
			territory.influence[factionName] = CONQUERING_FACTION_BONUS;
		}
	}
	else {
		territory.influence[factionName] = newInfluence;
	}
}


/*
 * Keyboard controls
 */
function keyPressed() {
	if (key == ' ') {
		debugDraw = !debugDraw;
	}
	else if (key == 'q') {
		noLoop();
	}
}