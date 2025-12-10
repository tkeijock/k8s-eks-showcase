# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Download the aws-iam-authenticator binary to user's local bin
curl -o "$HOME/.local/bin/aws-iam-authenticator" \
  https://amazon-eks.s3-us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator

# Make the binary executable
chmod +x "$HOME/.local/bin/aws-iam-authenticator"

# Add ~/.local/bin to PATH permanently if not already present
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Apply the PATH change to the current session
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
aws-iam-authenticator help
