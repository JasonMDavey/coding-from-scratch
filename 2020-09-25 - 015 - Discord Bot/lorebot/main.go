package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	"github.com/bwmarrin/discordgo"

	"straybasilisk.com/lorebot/brain"
	"straybasilisk.com/lorebot/handlers"
)

func main() {
	// Loading Discord bot API token from text file
	token, err := loadToken("token.dat")
	if err != nil {
		fmt.Println("Error loading token:", err)
		return
	}

	// Construct a new Discord client
	discord, err := discordgo.New("Bot " + token)
	if err != nil {
		fmt.Println("Error creating Discord client:", err)
		return
	}
	brain.Init("lorePool.json", "knowledgeStore.json")

	err = brain.Validate()
	if err != nil {
		fmt.Println("Failed to validate:", err)
		return
	}

	// Register handlers
	discord.AddHandler(handlers.OnReady)
	discord.AddHandler(handlers.OnMessageCreate)

	// Actually connect to Discord
	if err := discord.Open(); err != nil {
		fmt.Println("Error opening Discord connection:", err)
		return
	}
	defer discord.Close()

	// Wait for cancel command
	fmt.Println("LoreBot is now running.  Press CTRL-C to exit.")
	sc := make(chan string)
	<-sc
}

func loadToken(filename string) (string, error) {
	// Open file
	file, err := os.Open(filename)
	if err != nil {
		return "", err
	}
	defer file.Close()

	// Read through file line-by-line, and return the first non-empty line
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		s := scanner.Text()
		if strings.TrimSpace(s) != "" {
			return s, nil
		}
	}

	if err := scanner.Err(); err != nil {
		return "", err
	}

	return "", fmt.Errorf("%v did not contain a token =(", filename)
}
