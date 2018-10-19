These are instructions for setting up a Dockerized Java WAR which 
- Has New Relic APM
- Can make calls into an Apigee proxy/endpoint


**test environment**
- Ubuntu 16


**prerequisites**
1) If you want to get as far as building this container and testing it locally, you will need:
- Docker
- Java 8 (Oracle)
- Apache Maven

2) For pushing the container to gcloud: we will follow this example: https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app


**Clone the source code**
- https://github.com/danstadler-newrelic/apigee-dt-frontend


**Step 1: download the New Relic agent**
- cd into the newrelic directory
- run this: 
```
wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.jar
```
- note that newrelic.yml is already there. Leave the app name and license key fields blank.


**Step 2: set up your environment variables**
- These can be used both for testing the container locally, as well as for building deploying it to K8S.
```
export PROJECT_ID="$(gcloud config get-value project -q)"
export PROJECT_NAME=apigee-dt-front
export PROJECT_PORT=8080
export PROJECT_VERSION=v1
export NEW_RELIC_APP_NAME=your-APM-app-name-here
export NEW_RELIC_LICENSE_KEY=your-license-key-here
export APIGEE_PROXY_URL=your-apigee-proxy-url
```

- NEW_RELIC_APP_NAME: the name you want this app to appear as in New Relic APM
- NEW_RELIC_LICENSE_KEY: your RPM license key, available here: https://rpm.newrelic.com/accounts/[my-rpm-id]/applications/setup
- APIGEE_PROXY_URL: the url you set up in Apigee, as a proxy to this example back-end project: https://github.com/danstadler-newrelic/apigee-dt-backend 


**Step 3: package the WAR file**
- From the project root directory:
```
cd journaldev-spring-mvc-example/spring-mvc-example/ ; mvn package ; cd ../..
```

**Step 4: build and test the container**
- Based on the gcloud public doc above, you could do the following to build the container:
```
docker build \
--build-arg newrelic_appname=${NEW_RELIC_APP_NAME} \
--build-arg newrelic_license=${NEW_RELIC_LICENSE_KEY} \
--build-arg apigee_proxy_url=${APIGEE_PROXY_URL} \
-t gcr.io/${PROJECT_ID}/${PROJECT_NAME}:${PROJECT_VERSION} .
```

You can test the container locally, as described in that doc:
```
docker run --rm -p ${PROJECT_PORT}:${PROJECT_PORT} gcr.io/${PROJECT_ID}/${PROJECT_NAME}:${PROJECT_VERSION}
```


**Step 5: deploy the container to K8S**
- Again basing this on the above doc. You could do the following:
```
docker push gcr.io/${PROJECT_ID}/${PROJECT_NAME}:${PROJECT_VERSION}

kubectl run ${PROJECT_NAME} --image=gcr.io/${PROJECT_ID}/${PROJECT_NAME}:${PROJECT_VERSION} --port ${PROJECT_PORT}
kubectl get pods
kubectl expose deployment ${PROJECT_NAME} --type=LoadBalancer --port 80 --target-port ${PROJECT_PORT}
kubectl get service
```
The last command will take some time but will eventually tell you your load balancer's IP address. We'll refer to that as LOAD_BAL.

note: if you rebuild/re-push the container, the kubectl command is slightly different. Use the docker push command on the new container image, and then use this:
```
kubectl set image deployment/${PROJECT_NAME} ${PROJECT_NAME}=gcr.io/${PROJECT_ID}/${PROJECT_NAME}:${PROJECT_VERSION}
```


**Step 6: test**
- this assumes that you have stood up:
- the back-end code: https://github.com/danstadler-newrelic/apigee-dt-backend
- an apigee proxy to the back-end code
- exported the correct env var for the proxy, i.e. export APIGEE_PROXY_URL=your-apigee-proxy-url

- go to your hosted app, like this: http://[LOAD_BAL]/spring-mvc-example/

You should see a "hello world" message, and a few lines down, you should see a successful response from the back-end.


