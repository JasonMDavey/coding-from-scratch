package handlers

import (
	"fmt"
	"strings"

	"github.com/bwmarrin/discordgo"

	"straybasilisk.com/lorebot/brain"
)

const (
	channelID = "759045447645134848" // #lorebot-test in Stray Basilisk Discord
)

// OnReady is called when a connection to Discord is first established
func OnReady(s *discordgo.Session, event *discordgo.Ready) {

	// Set the playing status.
	s.UpdateStatus(0, "@ me!")
}

// OnMessageCreate is called when a message is created in any channel the bot can see
func OnMessageCreate(s *discordgo.Session, m *discordgo.MessageCreate) {
	if m.Author.ID == s.State.User.ID {
		return
	}

	// Ignore messages which do not @ me
	atMe := fmt.Sprintf("<@!%v>", s.State.User.ID)
	if !strings.Contains(m.Content, atMe) {
		return
	}

	toSay := brain.GenerateResponse(m.Content)
	s.ChannelMessageSend(channelID, toSay)
}
