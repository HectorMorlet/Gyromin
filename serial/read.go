package serial

import (
	"bufio"
	"github.com/tarm/serial"
	"io"
	"strconv"
	"strings"
	"time"
)

var DataSubscription (chan [3]float64) = make(chan [3]float64)
var ErrorSubscription (chan string) = make(chan string)

func runService() {
	conf := &serial.Config{
		Name:        "/dev/cu.usbmodem1411",
		Baud:        115200,
		ReadTimeout: time.Second * 2,
	}
	s, err := serial.OpenPort(conf)

	if err != nil {
		go func() {
			ErrorSubscription <- "Failed to connect to Arduino!"
		}()
		return
	}

	defer s.Close()

	_, err = s.Write([]byte{'s'})
	if err != nil {
		println(err)
	}

	r := bufio.NewReader(s)

	lastMessage := ""

	for {
		rawLine, err := r.ReadString('\n')

		line := strings.Trim(rawLine, " \n\r")

		if len(line) < 3 {
			println("Received nothing")
			// break
		}

		if err != nil && err != io.EOF {
			ErrorSubscription <- "Error receiving data from Arduino!"
			return
		}

		if lastMessage != line {
			lastMessage = line

			result := [3]float64{0.0, 0.0, 0.0}

			index := 0
			substr := ""
			for i := 0; i < len(line); i++ {
				if line[i] != ' ' {
					substr += string(line[i])
				} else {
					result[index], err = strconv.ParseFloat(substr, 64)
					if err != nil {
						break
					}
					index++
					substr = ""
				}
			}

			result[index], err = strconv.ParseFloat(substr, 64)
			if err != nil || index != 2 {
				println("Corrupted data warning")
				continue
			}

			DataSubscription <- result
		}

		if err != nil {
			ErrorSubscription <- "End of Arduino stream"
			return
		}
	}
}

func RunService() {
	go func() {
		for {
			runService()
			println("Restarting service...")
			time.Sleep(time.Second)
		}
	}()
}
