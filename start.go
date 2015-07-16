package main

import (
	"github.com/googollee/go-socket.io"
	// "gyromin/bluetooth"
	"gyromin/serial"
	"log"
	"net/http"
)

func main() {
	serial.RunService()

	server, err := socketio.NewServer(nil)
	if err != nil {
		log.Fatal(err)
	}

	server.On("connection", func(so socketio.Socket) {
		so.Join("gyroscope-data")
	})

	server.On("error", func(so socketio.Socket, err error) {
		log.Println("error:", err)
	})

	http.Handle("/", http.FileServer(http.Dir("./web")))
	http.Handle("/socket.io/", server)

	log.Println("Serving at localhost:9000...")

	go func() {
		for {
			result := <-serial.DataSubscription
			// log.Println(result[0], result[1], result[2])
			server.BroadcastTo("gyroscope-data", "gyroscope",
				result[0], result[1], result[2])
		}
	}()

	go func() {
		for {
			err := <-serial.ErrorSubscription
			log.Println(err)
			server.BroadcastTo("gyroscope-data", "read-error", err)
		}
	}()
	log.Fatal(http.ListenAndServe(":9000", nil))
}
