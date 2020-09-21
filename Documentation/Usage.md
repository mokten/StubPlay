- [Using StubPlay](#using-stubplay)

# Using StubPlay

## Introduction

StubPlay lets you save http requests and responses and replay them inside the app or in your unit tests.

## Saving Requests
StubPlay provides a variety of convenience methods for making HTTP requests. 

```json
{
  "bodyFileName" : "b.get.0.body.txt",
  "rewriteRule" : {
        "host" : ".*.test.com"
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
    "headers" : {
      "Accept-Language" : "en;q=1.0",
      "User-Agent" : "Example-iOS\/0.1 (com.mokten.Example-iOS; build:1; iOS 12.1.0) Alamofire\/4.8.2",
      "Accept-Encoding" : "gzip;q=1.0, compress;q=0.5"
    }
  },
  "index" : 0
}
```


## Matching requests using regular expressions

### rewriteRule

Use host, method, path, params

For example match all requests that are part of `.test.com`

```json
  "rewriteRule" : {
        "host" : ".*.test.com"
    },
``` 
 

## Do not save a request's stub.

Request + Response file:

Add `skipSave : true`

```json
  "skipSave" : true,
``` 
 