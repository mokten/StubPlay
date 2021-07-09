- [Using StubPlay](#using-stubplay)

# Using StubPlay

## Introduction

StubPlay lets you save http requests and responses and replay them inside the app or in your unit tests.

## Saving Requests
StubPlay provides a variety of convenience methods for making HTTP requests. 

The following shows what the main request/response file would look like with all the options enabled.

Precedence is in the following order:
  1. doNotSaveStubRewriteRule
  1. rewriteRule
  
```json
{  
  "doNotSaveStubRewriteRule" : [
    {
      "host" : "a.com",
      "path" : "/a.temp"
    }
  ],
  "rewriteRule" : [
    {
        "host" : "a.com",
        "path" : "/a.txt"
    }
  ]
}
```

### Optional: rewriteRule

Use `rewriteRule` to add a rewrite rule in a matched and saved stub file.

If your saved stub has dynamic data in the request, and you want to replay the stub then this will save you time from manually adding the rewrite rule to the stub file.

Valid properties are:

host, method, path, params, body

For example, your client makes requests that has the current time in a query field.

https://a.com/a.txt?date=12345675
https://a.com/a.txt?date=23456788

```json
  "rewriteRule" : [
    {
        "host" : "a.com",
        "path" : "/multiple.txt"
    }
  ]
``` 

You can also use regex.

```json
  "rewriteRule" : [
    {
        "host" : "a\\.c.*"
    }
  ]
``` 

StubPlay will add this rewrite rule to the saved stub file.
You can now copy the saved stub files and replay them in your client.

Note: if there is a cached stub file with a rewrite rule then the global addToSavedStubRule will not be used.
 
## Optional: doNotSaveStubRewriteRule

Use doNotSaveStubRules to disable saving a request's stub.

This is similar to the skipSave in the saved stub file.

```json
  "doNotSaveStubRewriteRule" : [
    {
      "host" : "analytics.com",
    }
  ]
```
