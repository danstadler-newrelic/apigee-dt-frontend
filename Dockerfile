FROM bitnami/tomcat:latest
RUN mkdir -p /opt/newrelic/logs
RUN useradd tomcat
RUN chown -R tomcat /opt/newrelic/logs
ADD ./newrelic/newrelic.jar /opt/newrelic/newrelic.jar
ADD ./newrelic/newrelic.yml /opt/newrelic/newrelic.yml
ADD ./spring-mvc-example/target/spring-mvc-example.war /opt/bitnami/tomcat/webapps/
