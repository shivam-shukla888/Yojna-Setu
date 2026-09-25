# ==============================================================================
# Multi-Stage Production Dockerfile for Yojna Setu V2
# ==============================================================================

# Stage 1: Build & Package
FROM eclipse-temurin:21-jdk-jammy AS builder

WORKDIR /build

# Copy Maven wrapper & configuration first for optimal layer caching
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -B

# Copy source code and build production jar
COPY src/ ./src/
RUN ./mvnw clean package -DskipTests -B

# Stage 2: Hardened Runtime Container
FROM eclipse-temurin:21-jre-jammy AS runner

LABEL maintainer="Yojna Setu Engineering Team"
LABEL version="2.0.0"
LABEL description="Yojna Setu V2 — Hardened WhatsApp Government Scheme Discovery Assistant"

# Install curl for health checking and dumb-init for clean process reaping
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl dumb-init && \
    rm -rf /var/lib/apt/lists/*

# Create unprivileged system group & user (UID/GID 10001)
RUN groupadd -g 10001 yojnasetu && \
    useradd -u 10001 -g yojnasetu -m -s /sbin/nologin yojnasetu

WORKDIR /app

# Copy artifact from builder stage
COPY --from=builder --chown=yojnasetu:yojnasetu /build/target/yojna-setu-*.jar app.jar

# Switch to unprivileged user
USER yojnasetu:yojnasetu

# Expose standard Spring Boot port
EXPOSE 8080

# Production Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Environment Defaults for Container Runtime
ENV JAVA_TOOL_OPTIONS="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["java", "-jar", "app.jar"]
