# Radical

playground for EventStore persistent subscriptions

radical is a proof of concept of integrating extreme persistent subscriptions
and [`Broadway`](https://hexdocs.pm/broadway/Broadway.html)

`Radical.Producer` is a `GenStage` producer that starts and listens to a
persistent subscription.

`Radical.Handler` sets up the broadway pipeline and handles the events (by
printing them to the console and sleeping).
