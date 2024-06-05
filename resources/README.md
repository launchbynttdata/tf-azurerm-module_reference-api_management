# API Management
The default provisioning of the APIManagement instance is `External` which means that the APIM instance is exposed to the internet.
See the below section on how to change the networking options to make the APIM instance private.

## Networking options

If the requirement is to have the APIM instance private on both frontend (consumers accessing APIM privately) and backend
(APIM accessing backend services privately), then this is only possible in the `Vnet Injection: Internal` mode which is only
supported in the `Developer` and `Premium` SKUs.

More details about the networking options can be found [here](https://learn.microsoft.com/en-us/azure/api-management/virtual-network-concepts)

Below are the different networking options available in APIM

- VNet Injection
  - Deploy to Vnet - External
  - Deploy to Vnet - Internal
- Connect privately using private endpoint
- Integrate with VNet for outbound requests

## Vnet Injection - Internal
Describes how to deploy an APIM instance in a Vnet in the `Internal` mode. This mode is only supported in the `Developer` and `Premium` SKUs.


### Setup process

- Create an NSG
- Create a Subnet in the Vnet
  - No delegation should be provided
  - Associate the NSG with the Subnet
- Create a Public IP with a mandatory DNS label (test-apim-000)
- Go to APIM -> Network -> Virtual Network tab


# DNS Configuration

In the `internal` mode, where the APIM is deployed in a Vnet, user needs to managed their own DNS to enable inbound access to APIM endpoints

## Use Azure provided DNS

By default, Azure uses the `azure-api.net` domain name for all APIM instances provisioned in Azure. In case of private instances,
users are required to created their own Private DNS Zone by the name of `azure-api.net` and create DNS records to map to the private IP
of the APIM in order to establish the DNS resolution.

Following steps are required to setup the DNS resolution:

- Create a Private DNS Zone by the name of `azure-api.net`
- Fetch the private IP of the APIM instance and create the below A records to point to that IP address

  ```bash

  <instance_name>.azure-api.net
  <instance_name>.portal.azure-api.net
  <instance_name>.developer.azure-api.net
  <instance_name>.management.azure-api.net
  <instance_name>.scm.azure-api.net
  ```
- Create a `Vnet Link` in the Private DNS Zone to link the Vnet where the APIM is deployed

Advantage of using this DNS is that the certificates for this domain `azure-api.net` are managed by Azure and are signed by trusted CAs,
hence we don't need to manage the root certs for downstream services. For example, if we have a App gateway that points to our APIM,
we don't have to copy the root certs of the APIM to the App Gateway cert trust store.

## Attach custom domain
Create a custom domain to associate with the API Management instance. Private domains can be created
in `Azure Private DNS Zone`. TLS can be enabled on APIM instance by creating self signed certs or certificates
issued by Private CA.

Note: In case of custom domain TLS, the root certificate must be uploaded to the trust stores of the downstream systems like
Application Gateway for them to validate the certificates successfully.

# Backend Services
APIM supports several different ways in which backend applications can be onboarded or published.

## Upload Root certs for backend tls
The root certificate of the backend server must be uploaded to the APIM service. This is required for the APIM service to
trust the backend server.
If we use AKS based certificate manager, then the root certificate of the Private-CA-Cluster-Issuer must be uploaded to the APIM service.

# Create an API

Two sample applications that are used for this demo can be found below
- [python-app](./python-app)
- [dotnetcore-app](./dotnetcore-app)

APIs can be created or onboarded in APIM by navigating to the `APIs` section in the APIM instance.

Select from the list of available options
- Define a new API
- Create from definition
- Create from Azure resource etc.

For demo purposes, I used `Create from definition` -> `OpenAPI`. Once this option is selected, user has the option to
either provide a URL for the OpenAPI spec or upload the file. The `upload` option only works when the URL is public.
In our case the application is deployed on a private AKS cluster with a private ingress, so I had to save the
swagger file and uploaded it to the APIM instance.

Select the following options
- Display Name: Any name
- URL Scheme: Both
- API URL suffix: Any context root that must be suffixed after the APIM URL. I chose `python`. The Base URL will be updated accordingly
- Gateways: Managed
- Version this API?: I left it empty

Hit the `Create` button.

## Update the backend

Once, the API is created, you must update the backend. Edit and add a target. For this demo, I used `HTTP(s) endpoint` and added the url of the backend
service which is deployed on the private k8s cluster exposed as a private ingress.

Provide credentials (if any)

## Subscription

By default, `Subscription required` is enabled. This means that the API is protected and requires a subscription key to access the API.
The subscription key can be found in the `Subscriptions` tab in the left panel. Copy the key for use while invoking the endpoint

## Test the API
You need to be logged in to the VM which is in the same Vnet or peered Vnet as the APIM instance. The VNet links must also be setup to resolve the APIM instance
DNS correctly.

Use the curl command below for testing

```bash
# GET url
curl https://dso-apim-eus-dev-000-apim-000.azure-api.net/python/ \
  -H "Ocp-Apim-Subscription-Key: <key>"

# POST url
curl -X POST https://dso-apim-eus-dev-000-apim-000.azure-api.net/python/access \
  -H "Ocp-Apim-Subscription-Key: <key>" \
  -H "Content-Type: application/json"  \
  -d '{"name": "Debasish", "server": "localhost"}'
```
