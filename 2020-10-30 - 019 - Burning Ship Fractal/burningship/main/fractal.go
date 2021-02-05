package main

import (
	"image/color"
	"math"
	"sync"
)

const (
	fractalMinX = -1.5
	fractalMaxX = 1.5
	fractalMinY = -1.0
	fractalMaxY = 1.0

	regionSize = 32
	numWorkers = 8
)

var (
	colors = []color.RGBA{
		color.RGBA{80, 80, 255, 255},
		//color.RGBA{255, 100, 0, 255},
		color.RGBA{0, 0, 0, 255},
	}
)

type fractalParams struct {
	zoom          float64
	maxIterations int
	maxDistance   float64
	panX          float64
	panY          float64
}

type region struct {
	xMin int
	xMax int
	yMin int
	yMax int
}

// GenerateFractal generates a fractal!
func GenerateFractal(game *Game) {
	for {
		// TODO: pool/dispose of these textures more intelligently
		/*buffer, err := ebiten.NewImage(width, height, ebiten.FilterDefault)
		if err != nil {
			panic("Failed to create image " + err.Error())
		}
		*/
		buffer := make([]color.RGBA, width*height)

		maxRegions := math.Ceil(float64(width)/float64(regionSize)) * math.Ceil(float64(height)/float64(regionSize))
		regionQueue := make(chan region, int(maxRegions))

		params := game.params

		for xMin := 0; xMin < width; xMin += regionSize {
			for yMin := 0; yMin < height; yMin += regionSize {
				regionQueue <- region{
					xMin: xMin,
					xMax: int(math.Min(width-1, float64(xMin+regionSize))),
					yMin: yMin,
					yMax: int(math.Min(height-1, float64(yMin+regionSize))),
				}
			}
		}

		wg := sync.WaitGroup{}
		wg.Add(numWorkers)
		for i := 0; i < numWorkers; i++ {
			go func() {
				computeRegionsFromQueue(regionQueue, params, buffer)
				wg.Done()
			}()
		}
		wg.Wait()

		game.LatestFractalImage = buffer
		println("Frame done")
	}

}

func computeRegionsFromQueue(queue chan region, params fractalParams, buffer []color.RGBA) {
	for {
		select {
		case r := <-queue:
			computeRegion(r, params, buffer)
		default:
			return // No more work to be done
		}
	}
}

func computeRegion(r region, params fractalParams, buffer []color.RGBA) {
	maxDistanceSquared := params.maxDistance * params.maxDistance

	for x := r.xMin; x < r.xMax; x++ {
		for y := r.yMin; y < r.yMax; y++ {
			cReal, cImag := mapToFractalSpace(x, y, params)
			real, imag := cReal, cImag

			iteration := 0
			for (real*real+imag*imag) < maxDistanceSquared && iteration < params.maxIterations {
				tmp := real*real - imag*imag + cReal
				imag = math.Abs(2.0*real*imag) + cImag
				real = tmp
				iteration++
			}

			buffer[y*width+x] = mapColor(iteration, params)
		}
	}
}

// Maps from screen coordinates (going from 0=>width in x, and 0=>height in y)
// to fractal space (-2.5->1 in x, 1=>-1 in y)
func mapToFractalSpace(x int, y int, params fractalParams) (float64, float64) {
	scaleX := fractalMaxX - fractalMinX
	scaleY := fractalMaxY - fractalMinY
	mappedX := (float64(x)/float64(width))*scaleX + fractalMinX
	mappedY := (float64(y)/float64(height))*scaleY + fractalMinY
	mappedX = mappedX/params.zoom + params.panX
	mappedY = mappedY/params.zoom + params.panY
	return mappedX, mappedY
}

func mapColor(iteration int, params fractalParams) color.RGBA {
	ratio := float64(iteration) / float64(params.maxIterations)

	index := ratio * float64(len(colors)-1)
	lowIndex := math.Floor(index)
	frac := float32(index - lowIndex)
	frac *= frac
	invFrac := float32(1 - frac)

	lowColor := colors[int(lowIndex)]
	highColor := colors[int(math.Min(float64(len(colors)-1), lowIndex+1))]

	return color.RGBA{
		uint8(float32(lowColor.R)*invFrac + float32(highColor.R)*frac),
		uint8(float32(lowColor.G)*invFrac + float32(highColor.G)*frac),
		uint8(float32(lowColor.B)*invFrac + float32(highColor.B)*frac),
		255,
	}
}
