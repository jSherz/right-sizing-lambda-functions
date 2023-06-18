# right-sizing-lambda-functions

This project accompanies [a blog post on jSherz.com] that describes how to
dynamically choose the sized Lambda function to process a file uploaded into an
S3 bucket, e.g. processing user uploads.

[a blog post on jSherz.com]: https://jsherz.com/aws/lambda/2023/06/18/right-sizing-lambda-functions-that-process-files.html

## Getting started

1. Install Terraform version 1.4.x.
2. Install NodeJS 18.
3. Follow the instructions in the README.md in the `lambda` folder.

   ```bash
   cd lambda

   corepack enable
   yarn install
   ```

4. Deploy the resources:

    ```bash
    cd infrastructure

    terraform init
    terraform apply
    ```

If you'd like to give it a go, try generating three different sized files:

```
dd if=/dev/zero of=small bs=1 count=256
dd if=/dev/zero of=medium bs=1M count=2
dd if=/dev/zero of=large bs=1M count=30
```

Upload them to the S3 bucket created by the project. It's name was displayed
as an output when you ran `terraform apply` above.

You can run the following CloudWatch Logs Insights query to see the files being
processed by the three different Lambda functions:

```
filter message == "pretended to process file"
| fields @timestamp, message, function_name, object
| sort @timestamp desc
| limit 20
```
