# Diet Error Handler

This is a simple [Sinatra](http://www.sinatrarb.com/) app that is used as a
replacement to [Sentry](https://sentry.io) and [Errbit](https://errbit.com/) in
the end-to-end test environment.

The usage of Errbit is deprecated and once no more of our apps use it we'll
remove that integration.

It is used as means to create log files of errors that applications have
reported. Otherwise you have to find the errors in the individual application
STDOUT logs which can be very difficult.
