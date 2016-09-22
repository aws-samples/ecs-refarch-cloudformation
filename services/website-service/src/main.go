package main

import (
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

const VERSION string = "1.0.0"

type Product struct {
	ID          string
	Title       string
	Description string
	Price       float64
}

func main() {

	// Products template
	html := `
	<html>
		<head>
			<title>Product Listing</title>
		</head>
		<body>
			<h1>Product Listing</h1>
			{{range .}}
			<h2>{{.Title}}</h2>	
			<p><b>ID</b>: {{.ID}}</p>
			<p><b>Description</b>: {{.Description}}</p>
			<p><b>Price</b>: {{.Price}}</p>
			{{end}}
		</body>
	</html>
	`
	tmpl, err := template.New("product-listing").Parse(html)
	if err != nil {
		log.Fatalf("Error parsing product listing template: %s", err)
	}

	router := gin.Default()
	router.SetHTMLTemplate(tmpl)

	// Router handlers
	router.GET("/", func(c *gin.Context) {

		product := os.Getenv("PRODUCT_SERVICE_URL")
		resp, err := http.Get("http://" + product)
		if err != nil {
			c.IndentedJSON(500, gin.H{
				"status":   "error",
				"message":  "Could not connect to product service",
				"detailed": err.Error(),
			})
			return
		}

		defer resp.Body.Close()

		var products []Product
		json.NewDecoder(resp.Body).Decode(&products)
		c.HTML(200, "product-listing", products)

	})

	// Lets go...
	router.Run(":8000")

}
