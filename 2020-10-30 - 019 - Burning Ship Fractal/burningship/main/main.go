package main

import (
	"image/color"
	"log"

	"github.com/hajimehoshi/ebiten"
)

const (
	width       = 900
	height      = 600
	scaleFactor = 1.5
)

// Game implements ebiten.Game interface.
type Game struct {
	LatestFractalImage []color.RGBA
	started            bool

	params fractalParams
}

// Update proceeds the game state.
// Update is called every tick (1/60 [s] by default).
func (g *Game) Update(*ebiten.Image) error {
	// Write your game's logical update.
	if !g.started {
		go GenerateFractal(g)
		g.started = true
	}

	return nil
}

// Draw draws the game screen.
// Draw is called every frame (typically 1/60[s] for 60Hz display).
func (g *Game) Draw(screen *ebiten.Image) {
	latestImage := g.LatestFractalImage

	if latestImage == nil {
		// No frames have been generated - bail out
		return
	}

	// User input
	if ebiten.IsKeyPressed(ebiten.KeyPageUp) {
		g.params.maxIterations += 4
		println("Max iterations:", g.params.maxIterations)
	}
	if ebiten.IsKeyPressed(ebiten.KeyPageDown) && g.params.maxIterations >= 4 {
		g.params.maxIterations -= 4
		println("Max iterations:", g.params.maxIterations)
	}
	if ebiten.IsKeyPressed(ebiten.KeyKPAdd) {
		g.params.zoom *= 1.25
	}
	if ebiten.IsKeyPressed(ebiten.KeyKPSubtract) && g.params.zoom > 1 {
		g.params.zoom /= 1.25
	}
	if ebiten.IsKeyPressed(ebiten.KeyLeft) {
		g.params.panX -= 0.1 / g.params.zoom
	}
	if ebiten.IsKeyPressed(ebiten.KeyRight) {
		g.params.panX += 0.1 / g.params.zoom
	}
	if ebiten.IsKeyPressed(ebiten.KeyUp) {
		g.params.panY -= 0.1 / g.params.zoom
	}
	if ebiten.IsKeyPressed(ebiten.KeyDown) {
		g.params.panY += 0.1 / g.params.zoom
	}
	if ebiten.IsKeyPressed(ebiten.KeyI) {
		println("Zoom:", g.params.zoom)
		println("panX:", g.params.panX)
		println("panY:", g.params.panX)
	}

	// Blit latest fractal image to screen
	pixelIndex := 0
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			screen.Set(x, y, g.LatestFractalImage[pixelIndex])
			pixelIndex++
		}
	}
	//screen.DrawImage(latestImage, nil)
}

// Layout takes the outside size (e.g., the window size) and returns the (logical) screen size.
// If you don't have to adjust the screen size with the outside size, just return a fixed size.
func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return width, height
}

func main() {
	game := &Game{}
	game.params = fractalParams{}
	game.params.zoom = 1
	game.params.maxIterations = 64
	game.params.maxDistance = 4

	// Sepcify the window size as you like. Here, a doulbed size is specified.
	ebiten.SetWindowSize(width*scaleFactor, height*scaleFactor)
	ebiten.SetWindowTitle("Your game's title")

	// Call ebiten.RunGame to start your game loop.
	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
