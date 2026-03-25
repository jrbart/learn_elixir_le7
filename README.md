Using the project with Users that were fitted with Ecto, we're going to add some new functionality to our application. For each request that goes to our GraphQL server, we're going to store its hit to an aggregate of all hits to that resolver. This should be stored inside a process and be ephemeral data. It should store data in the format of:

%{"create_user" => 10}
To view this data, we're going to create a GraphQL query for viewing a resolver's hits:

query {
  resolverHits(key: "create_user")
}
Hint: Because field returns are types, we can specify :integer as a return type.

Lastly, we're going to write integration tests for all your queries, mutations, and subscriptions, as well as for our ephemeral data-holding process.

Make sure you delete the _build and deps folder, and zip up your project in a ".zip" or ".tar.gz" before uploading, please also name your project_project_my_name for example my_app_mika that way I can identify it easier.

Estimated Turnaround Time: 2 Business Day
