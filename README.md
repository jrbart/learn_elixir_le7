Scalability & Distribution Assignment
===

To scale up the application we’ve been building, we need to make a few
upgrades and add some new features.


Resolve Counter Upgrade
---

To achieve a higher scale, we need to upgrade our resolver counter since 
it's triggered on every request. How you approach this is up to you, but
it must operate much faster than a single process can handle. **No external
libraries are allowed for this.**


GenStage Pipeline
---

Now that we have all our emails in place, we’re going to write a system
to process all users daily and generate an auth token unique to each user.
This token will be stored in a cache and made available for retrieval by
the user. For this task, **no external libraries are allowed.**

We’ll create a GenStage system that will:

1. Produce users.

2. Allow consumers to generate tokens for each user.

3. Remove stale tokens as necessary.


GQL Modifications
---

With auth tokens being generated, we need a way to retrieve them for
users using GraphQL. Here’s what we’ll do:

1. Add an _auth_token_ field to the _User_ type, which will return the token
from our cache for the specified user.

Add a subscription:

````
subscription {
userAuthToken(user_id: String!): String
}
````

This subscription will trigger whenever a new token is generated for a
specific _user_id_.


Distribution Setup
---

We’re going to scale our server by adding nodes. Use LibCluster for
this, and set up two nodes in development:

    _node_a@localhost_

    _node_b@localhost_


Optional Challenge
---

If you’re up for an extra challenge:

    Allow specific user tokens to be passed through.

    Create a query to return the current user for a given token.


Make sure you delete the _build and deps folder

Estimated Turnaround Time: _3 Business Day_
