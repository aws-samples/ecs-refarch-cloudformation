package main

import "github.com/gin-gonic/gin"

type product struct {
	ID          string
	Title       string
	Description string
	Price       float64
}

func main() {

	router := gin.Default()

	// Respond to GET requests
	router.GET("/products", func(c *gin.Context) {

		products := []product{
			product{
				ID:          "0000-0000-0001",
				Title:       "Fork Handles",
				Description: "Got forks? Worn out ones? You need our all new Fork Handles",
				Price:       6.95,
			},
			product{
				ID:          "0000-0000-0002",
				Title:       "Four Candles",
				Description: "One candle never enough? You need our new Four Candles bundle",
				Price:       3.75,
			},
			product{
				ID:          "0000-0000-0003",
				Title:       "Egg Basket",
				Description: "Holds 6 unbroken eggs or 36 broken ones",
				Price:       9.99,
			},
		}

		c.IndentedJSON(200, products)

	})

	// Serve all of the things..
	router.Run(":8001")

}
