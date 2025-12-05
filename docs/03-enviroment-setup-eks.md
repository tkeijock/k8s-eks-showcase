In the development environment, I used a single EC2 instance to run a Minikube cluster.
Now, I will use my local machine to connect publicly to the EKS cluster.

Before proceeding, a few prerequisites are required, including version checks:

### 1️⃣ Local machine:

Running Ubuntu 18.04.01 LTS

### 2️⃣ AWS CLI Updated 

Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Check your version with:

```bash aws --version  ``` 

 The AWS CLI must be at version ≥ 1.17.9 (latest version recommended) to ensure full official support for EKS commands (```aws eks ...```). 

Note: Version 1.16.73 introduced the initial EKS-related commands, but 1.17.9 includes broader functionality and improved command coverage.

### 3️⃣ Kubectl updated

Check your version with:
```bash kubectl version ```

Using a compatible kubectl version is important to avoid “version skew” issues. 
While AWS does not require an exact version match, the official EKS documentation recommends keeping kubectl within the same minor version as the cluster — or at most one minor version above or below.

For example, if the EKS cluster is running Kubernetes 1.32, the recommended kubectl versions are 1.32, 1.31, or 1.33. 
As a best practice, you should always update kubectl whenever you upgrade your EKS cluster to ensure full compatibility with the Kubernetes API.

consult eks versions on : https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html?utm_source=chatgpt.com
