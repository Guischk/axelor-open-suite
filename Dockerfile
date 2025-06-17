# Base image with OpenJDK 11 for building
FROM openjdk:11-jdk as builder

# Install necessary tools for building the application
RUN apt-get update && apt-get install -y git curl unzip sed

# Accept build arguments
ARG GRADLE_VERSION=7.6
ARG AXELOR_REPO=https://github.com/axelor/open-suite-webapp.git
ARG AXELOR_VERSION=8.0
ARG AXELOR_DB_URL=jdbc:postgresql://postgres:5432/axelor
ARG AXELOR_DB_USER=axelor
ARG AXELOR_DB_PASSWORD=axelor

# Set environment variables
ENV GRADLE_VERSION=${GRADLE_VERSION}
ENV AXELOR_REPO=${AXELOR_REPO}
ENV AXELOR_VERSION=${AXELOR_VERSION}
ENV APP_HOME=/opt/axelor

# Install Gradle
RUN curl -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle.zip && \
    unzip gradle.zip -d /opt && \
    rm gradle.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle

# Clone Axelor source code for specified version
RUN git clone ${AXELOR_REPO} ${APP_HOME} && \
    cd ${APP_HOME} && \
    git checkout ${AXELOR_VERSION}

# Update the .gitmodules file with the correct URL
RUN sed -i 's|git@github.com:axelor/axelor-open-suite.git|https://github.com/axelor/axelor-open-suite.git|g' ${APP_HOME}/.gitmodules && \
    cd ${APP_HOME} && \
    git submodule init && \
    git submodule update && \
    git submodule foreach git checkout ${AXELOR_VERSION}

# Ensure axelor-config.properties lines are replaced or appended
RUN CONFIG_FILE=${APP_HOME}/src/main/resources/axelor-config.properties && \
    touch $CONFIG_FILE && \
    sed -i '/^db.default.url/d' $CONFIG_FILE && echo "db.default.url=${AXELOR_DB_URL}" >> $CONFIG_FILE && \
    sed -i '/^db.default.user/d' $CONFIG_FILE && echo "db.default.user=${AXELOR_DB_USER}" >> $CONFIG_FILE && \
    sed -i '/^db.default.password/d' $CONFIG_FILE && echo "db.default.password=${AXELOR_DB_PASSWORD}" >> $CONFIG_FILE && \
    # sed -i '/^db.default.schema/d' $CONFIG_FILE && echo "db.default.schema=public" >> $CONFIG_FILE && \
    sed -i '/^file.upload.dir/d' $CONFIG_FILE && echo "file.upload.dir=/usr/local/tomcat/data/uploads" >> $CONFIG_FILE && \
    sed -i '/^data.export.dir/d' $CONFIG_FILE && echo "data.export.dir=/usr/local/tomcat/data/export" >> $CONFIG_FILE && \
    # sed -i '/^hibernate.search.default.indexBase/d' $CONFIG_FILE && echo "hibernate.search.default.indexBase=/usr/local/tomcat/data/indexes" >> $CONFIG_FILE && \
    # sed -i '/^hibernate.hbm2ddl.auto/d' $CONFIG_FILE && echo "hibernate.hbm2ddl.auto=update" >> $CONFIG_FILE && \
    # sed -i '/^hibernate.dialect/d' $CONFIG_FILE && echo "hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect" >> $CONFIG_FILE && \
    # sed -i '/^logging.level.root/d' $CONFIG_FILE && echo "logging.level.root=DEBUG" >> $CONFIG_FILE && \
    # sed -i '/^logging.level.org.hibernate/d' $CONFIG_FILE && echo "logging.level.org.hibernate=DEBUG"
    >> $CONFIG_FILE

# Build the Axelor application
RUN cd ${APP_HOME} && gradle war

# Use Tomcat as the final runtime image
FROM tomcat:9-jdk11

# Remove the existing ROOT application in Tomcat (if any)
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the WAR file built in the previous stage as ROOT.war ---> this is the default application --> http://localhost:7070 instead of http://localhost:7070/axelor
COPY --from=builder /opt/axelor/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

# Copy the generated axelor-config.properties file to Tomcat's conf directory
COPY --from=builder /opt/axelor/src/main/resources/axelor-config.properties /usr/local/tomcat/conf/axelor-config.properties

# Set file upload and export directories
RUN mkdir -p /usr/local/tomcat/data/uploads /usr/local/tomcat/data/export /usr/local/tomcat/data/indexes && \
    chmod -R 777 /usr/local/tomcat/data

# Accept port argument for cloud deployment compatibility
ARG AXELOR_PORT=7070

# Create a startup script that handles dynamic port configuration for cloud hosting
RUN echo '#!/bin/bash\n\
# Use PORT environment variable if set (for Railway/cloud hosting), otherwise use build arg\n\
export TOMCAT_PORT=${PORT:-'"${AXELOR_PORT}"'}\n\
# Update server.xml with the correct port\n\
sed -i "s/port=\"8080\"/port=\"$TOMCAT_PORT\"/g" /usr/local/tomcat/conf/server.xml\n\
# Start Tomcat\n\
exec catalina.sh run' > /usr/local/tomcat/bin/start-axelor.sh && \
    chmod +x /usr/local/tomcat/bin/start-axelor.sh

# Expose port (configurable via build arg)
EXPOSE ${AXELOR_PORT}

# Use the startup script that handles dynamic port configuration
CMD ["/usr/local/tomcat/bin/start-axelor.sh"]
