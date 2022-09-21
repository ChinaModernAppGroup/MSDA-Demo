# Import the MSDA-K8S rpm package

Follow the instructions to import the MSDA-K8S rpm package into BIG-IP.

# Get the base64 format certificate for authentication

For a quick demo, you can use cert in the ./kube/config, for example:
```
ubuntu@k8smaster:~$ cat .kube/config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1Ea3hOekV5TkRnME0xb1hEVE15TURreE5ERXlORGcwTTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJB
    
    
    server: https://10.1.20.4:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJUWFMYkpwbDdpNHN3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TWpBNU1UY3hNalE0TkROYUZ3MHlNekE1TVRjeE1qUTRORFphTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpM
    
    
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBc3dtaTkwWUszcmhYQTdlRGM0bjdUUmhURlBCdTQxOUsyeC9Yb210bTZVM2hLSVIrCmhsQ3RnZm05SHVPRWpTempSa3VnUTh0ak5UWm51Wm04by9uMUo0ZGFZS0g4ODRqR2M1N00xU0dCeUJrdnVsMlgKcEFLUDBJeGd5MVhYMUE4amtXQU9oL3NDVFRLb2dYcTNBZC85QmlST3M3Uzd2T3JlWW1EM1hCaXpp

    
ubuntu@k8smaster:~$
```

# Deploy a MSDA-K8S applications LX

Follow up the instructions to deploy a MSDA-K8S applications LX via WebUI of API.
