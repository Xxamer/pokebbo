FROM elixir:1.20.0-otp-27

# Install dependencies
RUN apt-get update && \
  apt-get install -y curl gnupg inotify-tools && \
  curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
  apt-get install -y nodejs && \
  node -v && npm -v

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create required dirs
RUN mkdir -p /app /home/ubuntu

# Set user permissions
RUN chown -R $USER_ID:$GROUP_ID /app /home/ubuntu
USER $USER_ID:$GROUP_ID
ENV HOME=/home/ubuntu

# Install hex and rebar
RUN mix local.hex --force
RUN mix local.rebar --force

# Set /app as workdir
WORKDIR /app