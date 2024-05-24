# Python app

This simple flask application is based on this public repository [Flask-app](https://github.com/DiptoChakrabarty/simple-docker-flask-app.git).
When this app is deployed, a swagger file is published at `/static/swagger.json` which can be used to create an API in APIM. This swagger file
is downloaded to [here](./sample-python-swagger.json) for convenience.

The docker image is also built and published to `dsopublic.azurecr.io/python-swagger:v1`.

The K8s manifest file can be found [here](./python-swagger-app.yaml). This manifest file is used to deploy the application on a private AKS cluster.
The ingress endpoint then is used as the backend in APIM.
