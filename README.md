These are instructions for setting up a Dockerized Java WAR which 
- Has New Relic APM
- Can make calls into an Apigee proxy/endpoint


**test environment**
- Ubuntu 16

**prerequisites**
- Docker
- Java 8 (Oracle)
- Apache Maven

**Clone the source code**
- https://github.com/danstadler-newrelic/apigee-dt-frontend



**Step 1: download the New Relic agent**
- cd into the project root directory
- mkdir newrelic
- cd newrelic
- run this:
wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.jar
- and run this:
wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic.yml

**Step 2: alter your Dockerfile to include New Relic settings**
- Change license key to your license key, available here: https://rpm.newrelic.com/accounts/[YOUR_RPM_ID]
- Change application name to something you’d like the app to show up as in New Relic APM


**Step 3: download and build the code for the sample project**

option 1) 

- we are downloading the completed code from this page: https://www.journaldev.com/14476/spring-mvc-example
- in the project root directory, run this:
wget https://www.journaldev.com/wp-content/uploads/spring/spring-mvc-example.zip
- unzip the downloaded zip file

option 2) 

- clone this repo (has BSD 2-clause license added): 
https://github.com/danstadler-newrelic/journaldev-spring-mvc-example



**Step 4: modify the application to call Apigee:**
- edit this file: spring-mvc-example/src/main/java/com/journaldev/spring/controller/HomeController.java

1 - add these import statements:

    import java.net.URL;
    import java.net.HttpURLConnection;
    import java.io.BufferedReader;
    import java.io.InputStreamReader;

2 - add this code to the home() function, just before its return statement:

                try {
                        // change this, or get from an external config value
                        URL url = new URL("http://mocktarget.apigee.net/");
                        HttpURLConnection con = (HttpURLConnection) url.openConnection();
                        con.setRequestMethod("GET");
                        int status = con.getResponseCode();
                        BufferedReader in = new BufferedReader(
                        new InputStreamReader(con.getInputStream()));
                        String inputLine;
                        StringBuffer content = new StringBuffer();
                        while ((inputLine = in.readLine()) != null) {
                            content.append(inputLine);
                        }
                        in.close();
                        String apigeeResponse = content.toString();
                        System.out.println(apigeeResponse);
                        model.addAttribute("apigeeResponse", apigeeResponse);
                } catch (Throwable t) {
                        System.out.println (t.toString());
                }


**Step 5: modify home.jsp to show the result from the call out to Apigee**
- edit this file: spring-mvc-example/WebContent/WEB-INF/views/home.jsp
- add this line: 
`<P>The response from the Apigee proxy was ${apigeeResponse}.</p>`


**Step 6: package the WAR file**
- in the spring-mvc-example directory, run this: mvn package


**Step 7: build the docker container, launch in K8S**

- note: depending on what you did in step 3: if you chose option 2 (git clone) then this line is fine in your dockerfile:
ADD ./journaldev-spring-mvc-example/spring-mvc-example/target/spring-mvc-example.war /opt/bitnami/tomcat/webapps/

- however if you chose option 1 (download zip) - then that line will need to be:
ADD ./spring-mvc-example/target/spring-mvc-example.war /opt/bitnami/tomcat/webapps/


- for building and deploying: will leave this up to the reader - use your existing processes for building and deploying containers



**Step 8: test**
- this assumes that you have stood up:
- the back-end code: https://github.com/danstadler-newrelic/apigee-dt-backend
- an apigee proxy to the back-end code
- altered the code in step 4 above, to point to your actual proxy, not to "http://mocktarget.apigee.net/"

- go to your hosted app, like this: [your-front-end-domain]/spring-mvc-example/

you should see a "hello world" message, and a few lines down, you should see a successful response from the back-end.


