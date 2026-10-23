require "graphql/rake_task"

# bin/rails graphql:schema:idl writes schema.graphql: the API contract for the
# frontend's type generation and for reviewing API changes in pull requests.
GraphQL::RakeTask.new(schema_name: "BdAssistantApiSchema", directory: Rails.root.to_s, idl_outfile: "schema.graphql")
