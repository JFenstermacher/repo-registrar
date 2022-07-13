package main

import (
	"context"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, request events.ALBTargetGroupRequest) (events.ALBTargetGroupResponse, error) {
	fmt.Printf("Processing request data for traceId %s.\n", request.Headers["x-amzn-trace-id"])
	fmt.Printf("Body size = %d.\n", len(request.Body))

	fmt.Println("Headers:")
	for key, value := range request.Headers {
		fmt.Printf("  %s: %s\n", key, value)
	}

	response := events.ALBTargetGroupResponse{
		Body:              request.Body,
		StatusCode:        200,
		StatusDescription: "200 OK",
		IsBase64Encoded:   false,
		Headers:           map[string]string{},
	}

	return response, nil
}

func main() {
	lambda.Start(HandleRequest)
}
