# Fake LLM Server

A simple server that mimics the OpenAI streaming chat completions API for testing purposes.

## Features

- Implements a basic version of the OpenAI chat completions API
- Supports both streaming and non-streaming responses
- Always responds with "hello world" message
- Configurable through environment variables

## Installation

```bash
npm install
```

## Usage

Start the server:

```bash
# Development mode
npm run dev

# Production mode
npm run build
npm start
```

### Example usage

```
curl -X POST http://localhost:3500/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Say something"}],"model":"any-model","stream":true}'
```

The server will be available at http://localhost:3500 by default.

## API Endpoints

### POST /v1/chat/completions

This endpoint mimics OpenAI's chat completions API.

#### Request Format

```json
{
  "messages": [{ "role": "user", "content": "Your prompt here" }],
  "model": "any-model",
  "stream": true
}
```

- Set `stream: true` to receive a streaming response
- Set `stream: false` or omit it for a regular JSON response

#### Response

For non-streaming requests, you'll get a standard JSON response:

```json
{
  "id": "chatcmpl-123456789",
  "object": "chat.completion",
  "created": 1699000000,
  "model": "fake-model",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "hello world"
      },
      "finish_reason": "stop"
    }
  ]
}
```

For streaming requests, you'll receive a series of server-sent events (SSE), each containing a chunk of the response.


## Configuration

You can configure the server by modifying the `PORT` variable in the code.

## Use Case

This server is primarily intended for testing applications that integrate with OpenAI's API, allowing you to develop and test without making actual API calls to OpenAI.
