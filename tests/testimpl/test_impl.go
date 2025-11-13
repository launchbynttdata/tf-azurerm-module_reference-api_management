package testimpl

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	apiManagement "github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/apimanagement/armapimanagement"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
)

func TestApiManagementModule(t *testing.T, ctx types.TestContext) {
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	if len(subscriptionId) == 0 {
		t.Fatal("ARM_SUBSCRIPTION_ID environment variable is not set")
	}

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		t.Fatalf("Unable to get credentials: %e\n", err)
	}

	resourceGroupName := terraform.Output(t, ctx.TerratestTerraformOptions(), "resource_group_name")
	serviceName := terraform.Output(t, ctx.TerratestTerraformOptions(), "api_management_name")

	t.Run("doesApiManagementApiExist", func(t *testing.T) {
		options := arm.ClientOptions{
			ClientOptions: azcore.ClientOptions{
				Cloud: cloud.AzurePublic,
			},
		}

		apiClient, err := apiManagement.NewAPIClient(subscriptionId, credential, &options)
		if err != nil {
			t.Fatalf("Error getting API Management api client: %v", err)
		}

		api, err := apiClient.Get(context.Background(), resourceGroupName, serviceName, "terratest-api", nil)
		if err != nil {
			t.Fatalf("Error getting API Management api: %v", err)
		}

		assert.Equal(t, "true", strconv.FormatBool(*api.Properties.IsCurrent), "The API Management API 'is_current' property does not match the expected value")
	})

	t.Run("doesApiManagementApiRespondWith200", func(t *testing.T) {
		options := arm.ClientOptions{
			ClientOptions: azcore.ClientOptions{
				Cloud: cloud.AzurePublic,
			},
		}

		apimClient, err := apiManagement.NewServiceClient(subscriptionId, credential, &options)
		if err != nil {
			t.Fatalf("Error getting API Management api client: %v", err)
		}

		apim, err := apimClient.Get(context.Background(), resourceGroupName, serviceName, nil)
		if err != nil {
			t.Fatalf("Error getting API Management api: %v", err)
		}

		hostName := *apim.Properties.HostnameConfigurations[0].HostName

		status := retry.DoWithRetry(t, "Check if the API is up and running", 6, 10*time.Second, func() (string, error) {
			res, err := http.Get(fmt.Sprintf("https://%s/terratest/v1/resource", hostName))
			return strconv.FormatInt(int64(res.StatusCode), 10), err
		})

		assert.Equal(t, "200", status)
	})
}
