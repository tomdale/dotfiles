FROM ubuntu:24.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install only the minimal prerequisites that chezmoi/dotfiles expect
RUN apt-get update && apt-get install -y \
    curl \
    git \
    zsh \
    sudo \
    locales \
    ca-certificates \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# Set up locale and timezone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Use the existing ubuntu user (UID 1000), give it sudo and set zsh as shell
RUN usermod -s /bin/zsh ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the ubuntu user
USER ubuntu
WORKDIR /home/ubuntu

# Create empty .zshrc to prevent zsh newuser wizard
RUN touch .zshrc

# No chezmoi installed - test the full one-liner:
# sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tomdale

CMD ["/bin/zsh"]
