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

# Terminology

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", "**SHALL**", "**SHALL NOT**", "**SHOULD**",
"**SHOULD NOT**", "**RECOMMENDED**", "**NOT RECOMMENDED**", "**MAY**", and "**OPTIONAL**" in this
document are to be interpreted as described in BCP 14 [@!RFC2119] [@!RFC8174] when, and only when,
they appear in all capitals, as shown here.

# Language, framework and design-pattern implementation
[openapi_transpiler_both.png](openapi_transpiler_both.png)

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

##### OpenAPI YAML
YAML for [OpenAPI](https://www.openapis.org). This will be used externally to tell other languages/frameworks the current state of this code-base, and will be used internally to synchronise this code-base.

#### Frontend
The API SDK MUST be in a separate folder to the views.

In addition to the 'Required parts' referenced above, frontends MUST have:
##### Views
##### API SDK
The API SDK is in charge of exposes abstractions to access the endpoints, for example rather than the generic:

     curl --header "Content-Type: application/json" \
          --request POST \
          --data '{"username":"xyz","password":"xyz"}' \
          http://localhost:3000/api/login

It should be expose something akin to `login(IUser) (err, string)`, with use like:

    err, token := login(user)
    if err != nil {
      // show alert to user with error
    } else {
      // redirect to logged-in page or `redirectUri` value
    }

#### Backend
There must be a REST (stateless) interface to the API. Additional interfaces—like WebSockets—MAY be provided.

In addition to the 'Required parts' referenced above, backends MUST have:
##### Routes
Depending on the design pattern used, these are sometimes called Controllers or Actors.

This MUST declare the endpoint—e.g.: `/entity_name/{id}`—and any logic, e.g.: a database query using an ORM. The endpoint MAY inherit from a global namespace, e.g.: `/api/v4`.

The database query MAY be extracted into a Route SDK, so it can be composed with the Route SDK or directly in the Controllers of other endpoints.

## Compiler
### Dynamic code-generation
The scope and features of dynamic code-generation is still being explored. This section will remain in TODO status until then.

### Static code-generation

Traverse the Abstract Syntax Tree (AST) using same language as targeting.

Concentrating on finding the difference in the models and routes, deterministically resolve:

#### OpenAPI YAML
At the centre of our model is YAML for OpenAPI. This will be used externally to tell other languages/frameworks the current state of this code-base, and will be used internally to synchronise this code-base.

###### Code-generation directionality decision
For example, if there is a `POST` route for the `User` entity in the OpenAPI but not the code-base, then: iff the OpenAPI file is newer, components related to this new route will be generated, else the OpenAPI file will be updated with the removal of this [old] route.

#### Docstrings
Modify docstring to correctly refer to each function/class (or whatever abstraction) parameter.

#### Tests
On backend(s) implement [3.3.1.1.6](#section-3.3.1.1.6)., on frontend(s) do similar.

#### Models
Adding or removing fields in a model MUST result in a change to the [schemas](https://github.com/OAI/OpenAPI-Specification/blob/OpenAPI.next/versions/3.0.0.md#schemaObject) in [OpenAPI](https://github.com/OAI/OpenAPI-Specification), the schema/validation in the next section, the views (if frontend), docstrings (if necessary) and the tests (in particular the mocks).

#### Validation
Changing the validation rules can often be done at the JSON-schema or Model [3.2.2.3](#section-3.2.2.3) layer, but sometimes it is done elsewhere, e.g.: email validation that confirms message delivery before allowing insert into model.

We are considering a function name in string syntax here, like:

```python
class User(Base):
  __tablename__ = 'users'
  email = Column(String, primary_key=True) # validation: 'email_validation()'
  name = Column(String)
```

Which will tell the compiler where you can find the function, which it will search for in this hierarchy:
##### Function symbol in file scope
##### Function symbol in same directory, but in `validators.<ext>` file
##### If not present, generate new function by this name in `validators.<ext>` file
This new function should be a boolean or `(err, bool)` or `Result<ErrorCls, bool>` depending on your language/framework's protocol for error propagation. Alternatively if you are implementing it for an already available validation library, then you CAN follow their conventions.

Rather than `throw`ing a `NotImplemented` exception, this function should always succeed. In the middle of the function body SHOULD be a single line comment with:
```
# TODO
```

#### Routes
#### Views

##### Mode
At some future point algorithms for merging views will be invented, but for now insert/overwrite is the only mode supported.

###### Overwrite/insert
Views should only be inserted. If there are views already, they should be overridden. Keeping with an auto-admin theme, views should be added under the `admin` subdirectory.

## Appendix
### Backend scaffold
To give a frontend example we will use Node.js with restify and an ORM, in TypeScript.

#### Directory structure
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
Contains `interface`s for Entities (models). Depending on the language, this isn't necessary as the model `struct` itself can be used as the type internally.

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
Clear modularisation here assists with testing and allows the tests to be more easily composed. Alternative approaches of putting the tests in same directory as the implementation their testing can be explored, but will only be preferred when this is the best-practice of the language/framework.

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
To give a frontend example we will use Angular (TypeScript & HTML).

#### Directory structure
```
.
|-- README.md
|-- angular.json
|-- package-lock.json
|-- package.json
|-- proxy.conf.json
|-- src
|   |-- api
|   |   |-- auth
|   |   |   |-- auth.interfaces.ts
|   |   |   |-- auth.service.spec.ts
|   |   |   `-- auth.service.ts
|   |   |-- server-status
|   |   |   |-- server-status.interfaces.ts
|   |   |   |-- server-status.service.spec.ts
|   |   |   `-- server-status.service.ts
|   |   |-- shared.ts
|   |   `-- user
|   |       |-- user.interfaces.ts
|   |       |-- user.service.spec.ts
|   |       `-- user.service.ts
|   |-- app
|   |   |-- admin
|   |   |   |-- admin.component.css
|   |   |   |-- admin.component.html
|   |   |   |-- admin.component.spec.ts
|   |   |   |-- admin.component.ts
|   |   |   |-- admin.module.ts
|   |   |   |-- admin.routes.ts
|   |   |   |-- user-crud-dialog
|   |   |   |   |-- user-crud.dialog.component.css
|   |   |   |   |-- user-crud.dialog.component.html
|   |   |   |   |-- user-crud.dialog.component.spec.ts
|   |   |   |   `-- user-crud.dialog.component.ts
|   |   |   `-- users-admin
|   |   |       |-- users-admin.component.css
|   |   |       |-- users-admin.component.html
|   |   |       |-- users-admin.component.spec.ts
|   |   |       `-- users-admin.component.ts
|   |   |-- app.component.css
|   |   |-- app.component.html
|   |   |-- app.component.spec.ts
|   |   |-- app.component.ts
|   |   |-- app.module.ts
|   |   |-- app.routes.ts
|   |   |-- auth
|   |   |   |-- auth.guard.spec.ts
|   |   |   |-- auth.guard.ts
|   |   |   |-- auth.interceptors.ts
|   |   |   |-- auth.module.spec.ts
|   |   |   |-- auth.module.ts
|   |   |   |-- auth.routes.ts
|   |   |   |-- login
|   |   |   |   |-- login.component.css
|   |   |   |   |-- login.component.html
|   |   |   |   |-- login.component.spec.ts
|   |   |   |   `-- login.component.ts
|   |   |   |-- logout
|   |   |   |   `-- logout.component.ts
|   |   |   |-- signinup
|   |   |   |   |-- signinup.component.css
|   |   |   |   |-- signinup.component.html
|   |   |   |   |-- signinup.component.spec.ts
|   |   |   |   `-- signinup.component.ts
|   |   |   `-- signup
|   |   |       |-- signup.component.css
|   |   |       |-- signup.component.html
|   |   |       |-- signup.component.spec.ts
|   |   |       `-- signup.component.ts
|   |   |-- secret-dashboard
|   |   |   |-- secret-dashboard.component.css
|   |   |   |-- secret-dashboard.component.html
|   |   |   |-- secret-dashboard.component.spec.ts
|   |   |   |-- secret-dashboard.component.ts
|   |   |   |-- secret-dashboard.module.spec.ts
|   |   |   |-- secret-dashboard.module.ts
|   |   |   `-- secret-dashboard.routes.ts
|   `-- tslint.json
|-- tsconfig.json
`-- tslint.json
```

# Done
End

{backmatter}
