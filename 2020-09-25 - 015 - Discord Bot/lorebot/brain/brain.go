package brain

import (
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"sync"
)

// breadcrumb represents a single piece of information the bot can disclose
type breadcrumb struct {
	Text    string
	Prereqs []string
	Reveals []string
}

// keyword represents a flag/token which can be unlocked by users mentioning particular trigger words
type keyword struct {
	Triggers [][]string
	Reveal   string
}

// lore represents the entire pool of breadcrumbs and keywords known by the bot
type lore struct {
	Breadcrumbs []breadcrumb
	Keywords    []keyword
}

var lorePool lore = lore{}    // The entire pool of breadcrumbs and keywords known by the bot
var knowledge map[string]bool // Knowledge tokens currently unlocked by the community of users
var mutex = sync.Mutex{}

var knowledgeStoreFilename string

// Init initialises the bot's brain, loading its lore pool and unlocked-knowledge state
func Init(lorePoolFilename string, knowledgeFilename string) error {
	mutex.Lock()
	defer mutex.Unlock()

	// Load knowledge store
	knowledgeStoreFilename = knowledgeFilename
	knowledge = make(map[string]bool)

	knowledgeFile, err := os.Open(knowledgeFilename)
	if err != nil {
		return err
	}
	defer knowledgeFile.Close()

	err = json.NewDecoder(knowledgeFile).Decode(&knowledge)
	if err != nil {
		return err
	}

	// Load lore pool
	loreFile, err := os.Open(lorePoolFilename)
	if err != nil {
		return err
	}
	defer loreFile.Close()

	err = json.NewDecoder(loreFile).Decode(&lorePool)
	return err
}

// Validate checks to see if all breadcrumbs in the lore pool are reachable
func Validate() error {
	knowledge = make(map[string]bool)

	unseenBreadcrumbs := make([]breadcrumb, len(lorePool.Breadcrumbs))
	for _, bc := range lorePool.Breadcrumbs {
		unseenBreadcrumbs = append(unseenBreadcrumbs, bc)
	}

	for len(unseenBreadcrumbs) > 0 {
		foundNewBreadcrumb := false
		for i, bc := range unseenBreadcrumbs {
			// Process any breadcrumbs for which prerequisite knowledge is present
			if prereqsMet(bc, knowledge) {
				foundNewBreadcrumb = true

				// Add all Reveals for this breadcrumb to our knowledge pool
				for _, r := range bc.Reveals {
					knowledge[r] = true
				}

				// Look for any keywords associated with words mentioned in this breadcrumb's text
				// Simulates users parroting back things to the Bot, as this can also unlock new knowledge
				for kw := range lookForKeywords(bc.Text) {
					knowledge[kw] = true
				}

				// Remove this element from the list of unseen breadcrumbs (swap with last element and then truncate)
				length := len(unseenBreadcrumbs)
				unseenBreadcrumbs[i] = unseenBreadcrumbs[length-1]
				unseenBreadcrumbs = unseenBreadcrumbs[:length-1]

				// We've modified the list we're iterating, so best break out
				break
			}
		}

		if !foundNewBreadcrumb {
			for _, bc := range unseenBreadcrumbs {
				fmt.Println("Could not reach breadcrumb: ", bc.Text)
			}
			return errors.New("Lore pool invalid: there were unreachable breadcrumbs")
		}
	}

	return nil
}

// persistKnowledgeStore persists the knowledge store to disk
func persistKnowledgeStore() error {
	// Open file
	file, err := os.Create(knowledgeStoreFilename)
	if err != nil {
		return err
	}

	err = json.NewEncoder(file).Encode(&knowledge)

	return err
}

// GenerateResponse returns a response to the specified input message
func GenerateResponse(msg string) string {
	mutex.Lock()
	defer mutex.Unlock()

	knowledgeDirty := false

	referencedKeywords := lookForKeywords(msg)

	// User mentioning particular words may have unlocked new knowledge
	for kw := range referencedKeywords {
		if _, alreadyKnown := knowledge[kw]; !alreadyKnown {
			knowledge[kw] = true
			knowledgeDirty = true
		}
	}

	toSay := pickEligibleBreadcrumb(referencedKeywords)

	// Bot deliverying a particular response may also have unlocked new knowledge
	for _, kw := range toSay.Reveals {
		if _, alreadyKnown := knowledge[kw]; !alreadyKnown {
			knowledge[kw] = true
			knowledgeDirty = true
		}
	}

	if knowledgeDirty {
		err := persistKnowledgeStore()
		if err != nil {
			fmt.Println("Error persisting knowledge store", err)
		}
	}

	return toSay.Text
}

// lookForKeywords check which (if any) keywords are contained in the message, and adds corresponding stuff to our knowledge base
func lookForKeywords(msg string) map[string]bool {

	// Check which (if any) keywords are contained in the message
	msgWords := extractWords(msg)

	referencedKnowledge := make(map[string]bool, len(msgWords))

	for _, keyword := range lorePool.Keywords {
		for _, trigger := range keyword.Triggers {
			allSubTriggersMatched := true
			for _, subTrigger := range trigger {
				if !msgWords[subTrigger] {
					allSubTriggersMatched = false
					break
				}
			}

			if allSubTriggersMatched {
				referencedKnowledge[keyword.Reveal] = true
				break
			}
		}
	}

	return referencedKnowledge
}

func extractWords(msg string) map[string]bool {
	// Split by spaces
	splitMsg := strings.Split(strings.ToLower(msg), " ")

	result := make(map[string]bool, len(splitMsg))

	for _, s := range splitMsg {
		// Strip any non-alphanumeric characters from each word
		word := ""
		for _, c := range s {
			if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') {
				word += string(c)
			}
		}

		result[word] = true
	}

	return result
}

func pickEligibleBreadcrumb(referencedKnowledge map[string]bool) breadcrumb {
	// figure out stuff which is eligible to be said
	type match struct {
		bc    breadcrumb
		count int
	}

	eligible := make([]match, 0, len(lorePool.Breadcrumbs))

	maxReferencesMatched := 0

	for _, bc := range lorePool.Breadcrumbs {
		if !prereqsMet(bc, knowledge) {
			continue
		}

		// Count how many referenced knowledge items relate to this breadcrumb
		// We'll only consider
		numReferencesMatched := 0
		for _, p := range bc.Prereqs {
			if referencedKnowledge[p] {
				numReferencesMatched++
			}
		}

		// Pre-filter breadcrumbs which don't at least match the current best number of matched references
		if numReferencesMatched >= maxReferencesMatched {
			maxReferencesMatched = numReferencesMatched
			eligible = append(eligible, match{bc, numReferencesMatched})
		}
	}

	if len(eligible) == 0 {
		panic("No eligible breadcrumbs =(")
	}

	// Do a final filter pass to remove any earlier-added breadcrumbs which don't match the final best total
	filteredEligible := make([]breadcrumb, 0, len(eligible))

	for _, m := range eligible {
		if m.count == maxReferencesMatched {
			filteredEligible = append(filteredEligible, m.bc)
		}
	}

	chosenIndex := rand.Int() % len(filteredEligible)
	return filteredEligible[chosenIndex]
}

func prereqsMet(bc breadcrumb, knowledge map[string]bool) bool {
	for _, prereq := range bc.Prereqs {
		known := knowledge[prereq]
		if !known {
			return false
		}
	}

	return true
}
