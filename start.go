package main

import (
	"github.com/googollee/go-socket.io"
	"gyromin/bluetooth"
	"log"
	"net/http"
)

func main() {
	go func() {
		bluetooth.RunBluetooth()
	}()

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
			receivedData := <-bluetooth.DataSubscription
			server.BroadcastTo("gyroscope-data", "gyroscope", receivedData)
		}
	}()
	log.Fatal(http.ListenAndServe(":9000", nil))
}
