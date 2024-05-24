# sample-dotnetcore-app

This application is based out of the git repo [dotnetcore-app](https://github.com/debasish-sahoo-nttd/sample-dotnetcore-app.git). Once the application is
deployed, a swagger file is published at `/swagger/v1/swagger.json` which can be used to create an API in APIM. This swagger file is
downloaded to [here](./sample-dotnetcore-app-swagger.json) for convenience.

The docker image is published to `dsopublic.azurecr.io/sample-dotnetcore-app`

Please check the `pipelines` directory in the repo for details about how to deploy the application
