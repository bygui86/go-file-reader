package main

import (
	"fmt"
	"os"
	"os/signal"
	"strconv"
	"sync"
	"syscall"
	"time"
)

var (
	filePath = "./source.txt"
	interval = 3

	waitGroup sync.WaitGroup
	ticker    *time.Ticker
	done      chan bool
)

func main() {
	readEnvVar()

	setup()

	err := checkFile()
	if err != nil {
		fmt.Printf("Error checking file: %s - Exit file reader \n", err.Error())
		os.Exit(1)
	}

	fmt.Printf("Start file reader: path '%s', interval '%d' seconds... \n", filePath, interval)

	waitGroup.Add(1)
	go readFileLoop()

	go signalsListener()

	waitGroup.Wait()

	fmt.Println("File reader stopped")
}

func readEnvVar() {
	filePathTemp := os.Getenv("FILE_PATH")
	if filePathTemp != "" {
		filePath = filePathTemp
	}
	intervalTemp, err := strconv.Atoi(os.Getenv("INTERVAL"))
	if err != nil {
		fmt.Printf("Error reading env var INTERVAL: %s - Default to 3... \n", err.Error())
		return
	}
	interval = intervalTemp
}

func setup() {
	done = make(chan bool, 1)
	ticker = time.NewTicker(time.Duration(interval) * time.Second)
}

func checkFile() error {
	_, err := os.Stat(filePath)
	if os.IsNotExist(err) {
		return err
	}
	return nil
}

func readFileLoop() {
	for {
		select {
		case <-done:
			fmt.Println("Read file loop completed")
			waitGroup.Done()
			return
		case t := <-ticker.C:
			readFile(&t)
		}
	}
}

func readFile(t *time.Time) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		fmt.Printf("Error reading file content at %+v: %s \n", t, err.Error())
	}
	fmt.Printf("File content at %s: '%s' \n", t.Format(time.RFC3339), string(data))
}

func signalsListener() {
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt, syscall.SIGTERM, syscall.SIGINT, syscall.SIGQUIT, syscall.SIGKILL)
	termSign := <-sigs
	if termSign != nil {
		fmt.Printf("Received termination signal '%s' \n", termSign.String())
	}
	shutdown()
}

func shutdown() {
	fmt.Println("Shutdown file reader")
	ticker.Stop()
	done <- true
}
