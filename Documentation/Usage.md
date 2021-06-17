- [Using StubPlay](#using-stubplay)

# Using StubPlay

## Introduction

StubPlay lets you save http requests and responses and replay them inside the app or in your unit tests.

## Saving Requests
StubPlay provides a variety of convenience methods for making HTTP requests. 

The following shows what the main request/response file would look like with all the options enabled.

```json
{
  "bodyFileName" : "b.get.0.body.txt",
  "rewriteRule" : {
        "method" : "get",
        "host" : ".*.test.com",
        "path" : "/multiple.txt",
        "params" : "c=d",
    },
  "skipSave" : true,
  "response" : {
    "headers" : {
    },
    "statusCode" : 200,
    "mimeType" : "text\/plain"
  },
  "request" : { 
    "method" : "get",
    "url" : "https:\/\/a.test.com\/multiple.txt?c=d",
    "headers" : {
      "Accept-Language" : "en;q=1.0",
      "User-Agent" : "Example-iOS\/0.1 (com.mokten.Example-iOS; build:1; iOS 12.1.0) Alamofire\/4.8.2",
      "Accept-Encoding" : "gzip;q=1.0, compress;q=0.5"
    }
  },
  "index" : 0
}
```

### Optional: rewriteRule

By default, StubPlay will match exactly using the request properties - method, url and body.

Use `rewriteRule` to match part of the url or even use regular expressions.

Valid properties are:

host, method, path, params, body

For example, match all requests that are part of `.test.com`

```json
  "rewriteRule" : {
        "host" : ".*.test.com"
    },
``` 
 

## Optional: skipSave

Use skipSave to disable saving a request's stub.

Request + Response file:

Add `skipSave : true`

```json
  "skipSave" : true,
``` 
 