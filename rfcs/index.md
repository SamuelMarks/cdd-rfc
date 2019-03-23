%%%
title = "Compiler Driven Development"
abbrev = "CDD"
area = "Internet"
workgroup = "Offscale.io"
keyword = ["compilers"]
#date = 2019-12-07T00:00:00Z

[seriesInfo]
name = "RFC"
value = "CDDv0.0.1"
status = "informational"

[[author]]
surname="Marks"
fullname="Samuel Marks"
organization = "Sydney Scientific"
  [author.address]
  email = "samuel@offscale.io"
%%%

{mainmatter}

# Overview
Modern multi-client software-engineering impedes speedy, quality development as code duplication is required at every tier.

Duplication catalyses short-cuts, trade-offs and inconsistencies in order to develop with sufficient agility.

To use a web-app example: routes & models of the backend are called from multiple frontends, each with their own Application Programming Interface (API) client, model abstraction, and views. Add in documentation and tests, and suddenly development speed plummets. Thus trade-offs between software-engineering quality and quicker delivery becomes standard.

Our approach supersedes the crux of these trade-offs by: traversing the Abstract Syntax Trees (ASTs) in one language, then transforming and merging schemas across to the next language(s).

This RFC specifies the scope of Compiler Driven Development (CDD).

# Language, framework and design-pattern implementation
To be compliant with CDD, one needs:

## Starter scaffold
The starter scaffold MUST have the following:

### Clear modularisation
The frontend(s) MUST be separate to the backend(s).

#### Required parts
##### Validators
##### Documentation (docstrings)
##### Tests
##### Auto-auditors
Automated systems for showing test & documentation coverage, and with a value of 100.00% for each

#### Frontend
The API SDK MUST be in a separate folder to the views.

In addition to the 'Required parts' referenced above, frontends MUST have:
##### Views
##### API SDK

#### Backend
There must be a REST (stateless) interface to the API. Additional interfaces—like WebSockets—MAY be provided.

In addition to the 'Required parts' referenced above, backends MUST have:
##### Routes
Depending on the design pattern used, these are sometimes called Controllers or Actors. This MUST declare the endpoint—e.g.: `/entity_name/{id}`—and any logic, e.g.: a database query using an ORM. The database query MAY be extracted into a Route SDK, so it can be composed with the Route SDK or directly in the Controllers of other endpoints.

## Compiler
### Dynamic code-generation
### Static code-generation

Traverse the Abstract Syntax Tree (AST) using same language as targeting.

Concentrating on finding the difference in the models and routes, deterministically resolve:

#### Docstrings
Modify docstring to correctly refer to each function/class (or whatever abstraction) paramater.

#### Tests
On backend implement `2.3.1.1.6.`, on frontend(s) do similar.

#### Models
Adding or removing fields in a model MUST result in a change to the [schemas](https://github.com/OAI/OpenAPI-Specification/blob/OpenAPI.next/versions/3.0.0.md#schemaObject) in [OpenAPI](https://github.com/OAI/OpenAPI-Specification), the schema/validation in the next section, the views, docstrings (if necessary) and the tests (in particular the mocks).

#### Validation
Changing the validation rules can often be done at the JSON-schema or `2.2.2.3`

#### Routes
#### Views

## Appendix
### Backend scaffold
#### Backend example:
```
.
|-- .dockerignore
|-- .editorconfig
|-- .gitignore
|-- Dockerfile
|-- README.md
|-- api
|   |-- auth
|   |   |-- middleware.ts
|   |   |-- models.d.ts
|   |   |-- models.ts
|   |   `-- routes.ts
|   `-- user
|       |-- admin.ts
|       |-- models.ts
|       |-- routes.ts
|       |-- sdk.ts
|       `-- utils.ts
|-- config.ts
|-- docker-compose.yml
|-- main.ts
|-- package-lock.json
|-- package.json
|-- swagger.yaml
|-- test
|   |-- SampleData.ts
|   |-- api
|   |   |-- auth
|   |   |   |-- auth_test_sdk.ts
|   |   |   |-- schema.json
|   |   |   |-- test_auth_api.ts
|   |   |   `-- users.json
|   |   `-- user
|   |       |-- schema.json
|   |       |-- test_user_api.ts
|   |       |-- user_mocks.ts
|   |       `-- user_test_sdk.ts
|   |-- share_interfaces.d.ts
|   |-- shared_tests.js
|   |-- shared_tests.ts
|   `-- shared_types.d.ts
|-- tsconfig.json
`-- tslint.json
```

To explain this example in detail, at the root is:

##### `Dockerfile` and `docker-compose.yml` so that the solution can be deployed trivially with containers

##### ignore files (`.dockerignore`, `.gitignore`)
To stop files & folders from being seen where they shouldn't

##### `.editorconfig`, `tslint.json`
Set editor defaults and linting

##### `package.json`, `package-lock.json`
Project name, version, dependencies & license

##### `api` directory with entity subdirectories
###### Entity subdirectory
Within the entity subsubdirectories are a number of files, each of which is described in detail below:
###### `middleware.ts`
Contains middleware functions for routes. Custom middleware functions can be added here. Sometimes a shared middleware function will be generated when 2 or more routes share common functionality (e.g.: Request Body must contain Entity0 and Entity1 where both have an equal shared ID).

###### `models.d.ts`
Contains `interface`s for Entities (models). Depending on the language, this isn't neccesary as the model `struct` itself can be used as the type internally.

###### `models.ts`
Contains the models. If relational, this will is where you would create primary and foreign keys, and other indices. Additionally this often has additional validation and a `toJSON` function, showing what needs to appear. In our TypeScript example scaffold, we use an `_omit: string[]` which is used to populate the output, e.g.: `_omit = ['password']` to exclude the `password` field from output.

###### `routes.ts`
Contains route implementation. Includes endpoints and 'controllers'. Depending on the language, this allows for middleware, actors, decorators, requires parent `class`es &etc.

###### `utils.ts`
Contains small utility functions that are only needed by this Entity. E.g.: custom error messages.

###### `sdk.ts`
  a) If the same route logic is required on multiple routes, then it's extracted into an SDK function.

  b) inlining of SDK: This will be on demand or if a sufficiently high optimisation level is given.


##### `test` directory with `api` subdirectory and entity subsubdirectories
These subsubdirectories

###### `schema.json`
JSON-schema to be used by validation middleware, and any other area where JSON-schema can be read (e.g.: tests can use it directly to confirm that response body is in correct format, and route middleware can use it directly to confirm request body is in correct format).

###### `test_user_api.ts`
Calls the SDK and shows test lifecycle dependencies, like so:
```typescript
describe('/api/auth', () => {
    beforeEach(done => sdk.unregister_all(mocks, () => done()));
    afterEach(done => sdk.unregister_all(mocks, () => done()));

    it('POST should login user', done => sdk.register_login(mocks[1], done));
});
```

###### `user_mocks.ts`
Contains the mocks for the entity in question, fake data with success and failure cases. JSON or a similar language-independent format is best here.

###### `user_test_sdk.ts`
Library SDK for use by Entity specific tests, as well as `import`ed and used by other dependent Entities.

Example:
```typescript
public unregister_all(users: User[], callback: TCallback<Error | IncomingMessageError, Response>) {
    mapSeries(users as any, (user: User, callb) =>
        waterfall([
                call_back => this.login(user, (err, res) =>
                    err == null ? call_back(void 0, res.header['x-access-token']) : call_back(err)
                ),
                (access_token, call_back) => this.user_sdk.unregister({ access_token }, (err, res) =>
                    call_back(err, access_token)
                ),
            ], callb
        ), callback as any);
}
```

### Frontend scaffold
To give a frontend example we will use Angular.

{backmatter}
