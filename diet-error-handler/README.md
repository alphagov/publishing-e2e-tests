# Diet Error Handler

This is a simple [Sinatra](http://www.sinatrarb.com/) app that is used as a
replacement to [Sentry](https://sentry.io) in the end-to-end test environment.

It is used as means to create log files of errors that applications have
reported. Otherwise you have to find the errors in the individual application
STDOUT logs which can be very difficult.
