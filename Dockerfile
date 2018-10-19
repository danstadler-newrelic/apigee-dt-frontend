FROM bitnami/tomcat:latest
ARG newrelic_appname=your-app-name
ARG newrelic_license=your-license-key
ARG apigee_proxy_url=your-apigee-proxy-url
RUN mkdir -p /opt/newrelic/logs
RUN useradd tomcat
RUN chown -R tomcat /opt/newrelic/logs
ADD ./newrelic/newrelic.jar /opt/newrelic/newrelic.jar
ADD ./newrelic/newrelic.yml /opt/newrelic/newrelic.yml
ADD ./journaldev-spring-mvc-example/spring-mvc-example/target/spring-mvc-example.war /opt/bitnami/tomcat/webapps/
EXPOSE 8080
ENV NEW_RELIC_APP_NAME=$newrelic_appname \
    NEW_RELIC_LICENSE_KEY=$newrelic_license \
    APIGEE_PROXY_URL=$apigee_proxy_url \
    TOMCAT_USERNAME=tomcat \
    TOMCAT_PASSWORD=tomcat \
    JAVA_OPTS=-javaagent:/opt/newrelic/newrelic.jar

