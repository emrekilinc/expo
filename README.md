# expo
expo is short for "Exception Police", which is an exception logger
uses REST model and MongoDB.

All requests must be sent with "token" parameter. If you do not sent "token"
parameter server will return **HTTP 401**. You can change the value of token 
in app.rb file or implement some complex authentication algorithm.
Here are the some queries you can do with **expo**

- Get all exceptions

    http://yourserver.com/exceptions?token=123

- Get latest 100 exceptions

    http://yourserver.com/exceptions/100?token=123

- Get all exceptions of a project(Note that **ART-1** is the unique project
  code)

    http://yourserver.com/exceptions/ART-1?token=123

- Get latest 100 exceptions of a project

    http://yourserver.com/exceptions/ART-1/100?token=123

- You can post to **http://yourserver.com/exception/new** for creating new
  exceptions. Here is the curl code : 

    ```
    curl -i -H 'Accept: application/json' -d 'project_code=ART-1&friendly=Newly created exception&thrown_date=2012-11-28 01:06:56 +0200&message=exc message&class_name=NoArgumentError&backtrace=noidea&token=123' http://localhost:4567/exception/new
    ```

For any other url that you specify, **expo** will return a json like this : 

    {
        status: 404,
        reason: "No such route has been found."
    }

expo is still in the development process. Many features will be added in time.
