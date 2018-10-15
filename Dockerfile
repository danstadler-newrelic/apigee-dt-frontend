FROM bitnami/tomcat:latest
RUN mkdir -p /opt/newrelic/logs
RUN useradd tomcat
RUN chown -R tomcat /opt/newrelic/logs
ADD ./newrelic/newrelic.jar /opt/newrelic/newrelic.jar
ADD ./newrelic/newrelic.yml /opt/newrelic/newrelic.yml
ADD ./spring-mvc-example/target/spring-mvc-example.war /opt/bitnami/tomcat/webapps/
EXPOSE 8080
ENV NEW_RELIC_APP_NAME=your-app-name-here \
    NEW_RELIC_LICENSE_KEY=your-license-key-here \
    TOMCAT_USERNAME=tomcat \
    TOMCAT_PASSWORD=tomcat \
    JAVA_OPTS=-javaagent:/opt/newrelic/newrelic.jar

