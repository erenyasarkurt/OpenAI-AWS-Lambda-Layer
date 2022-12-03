# OpenAI-AWS-Lambda-Layer

This is an AWS Lambda Layer providing the dependencies for the OpenAI package which allows you to easily develop Serverless OpenAI services, greatly reducing price and removing the complexity of managing the OpenAI dependencies yourself.

## Release

This is a pre-built layer zip which you can easily deploy to AWS Lambda through the management console or the AWS CLI:

[OpenAI 0.25.0 Download for Python 3.7 / 3.8 / 3.9](releases/openai-aws-lambda-layer.zip)

## Building

You can build the OpenAI layer yourself (requires Docker) and get the latest version and customize the Python version which you're building for:

```bash
$ cd openai-aws-lambda-layer
$ ./build/build.sh
#or specify Python version
$ ./build/build.sh 3.9
```

## Usage

This is an example that would work for Lambda Function URL's or API Gateway, make sure you enable one of them before deploying your function. It's also recommended to increase the timeout value to a minimum of 30 seconds in General Configuration because OpenAI is not fast (yet). After creating the layer using the zip file here or the one you've just built, copy and paste the example below in the Lambda Code Editor:

```py
import openai
import json
import datetime

def query_completion(prompt: str, engine: str = 'text-davinci-003', temperature: float = 0.5, max_tokens: int = 1500, top_p: int = 1, frequency_penalty: int = 0.5, presence_penalty: int = 0.2) -> object:
    """
    Function for querying GPT-3.
    """
    estimated_prompt_tokens = int(len(prompt.split()) * 1.6)
    estimated_answer_tokens = 2049 - estimated_prompt_tokens
    response = openai.Completion.create(
    engine=engine,
    prompt=prompt,
    temperature=temperature,
    max_tokens=min(4096-estimated_prompt_tokens, max_tokens),
    top_p=top_p,
    frequency_penalty=frequency_penalty,
    presence_penalty=presence_penalty
    )
    return response
    
def lambda_handler(event, context):
    '''Provide an event that contains the following keys:
      - prompt: text of an open ai prompt
    '''
    
    openai.api_key = "YOUR_KEY_HERE"
    
    print("Init:")
    print(datetime.datetime.now())
    print("Event:")
    print(event)

    body = json.loads(event['body'])
    prompt = body['prompt']
        
    max_tokens = 1500
    
    response = query_completion(prompt)
    response_text = response['choices'][0]['text'].strip()

    response = {
        "statusCode": 200,
        "headers": {},
        "body": response_text
    }

    return response
```

Make sure you don't forget to put in your own OpenAI key. Once the function is deployed, you can test it by doing a cURL request like the one below (replace the URL with your own Function URL):

```bash
$ curl --request POST 'https://your.lambda-url.us-west-1.on.aws/' --header 'Content-Type: application/json' --data-raw '{"prompt": "Generate a paragraph about if deploying OpenAI on AWS Lambda makes sense"}'
```

Here is a response:

```
Deploying OpenAI on AWS Lambda could be a great way to take advantage of the powerful capabilities of both platforms. With OpenAI, developers can build and deploy their own artificial intelligence models quickly and easily, while AWS Lambda provides a serverless platform for running code without having to manage any underlying infrastructure. This combination makes sense for businesses looking to quickly spin up AI models that require minimal maintenance or setup. Additionally, the scalability of AWS Lambda means that it can easily handle the increased demand from more complex AI models as they are built and deployed. All in all, deploying OpenAI on AWS Lambda is an excellent option for businesses looking to quickly get started with artificial intelligence technologies.
```