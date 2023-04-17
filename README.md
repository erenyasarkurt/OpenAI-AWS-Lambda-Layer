# OpenAI-AWS-Lambda-Layer

This is an AWS Lambda Layer providing the dependencies for the OpenAI package which allows you to easily develop Serverless OpenAI services, greatly reducing price and removing the complexity of managing the OpenAI dependencies yourself.

## Release

This is a pre-built layer zip which you can easily deploy to AWS Lambda through the management console or the AWS CLI:

[OpenAI 0.27.4 (Python 3.7)](releases/openai-aws-lambda-layer-3.7.zip)

[OpenAI 0.27.4 (Python 3.8)](releases/openai-aws-lambda-layer-3.8.zip)

[OpenAI 0.27.4 (Python 3.9)](releases/openai-aws-lambda-layer-3.9.zip)

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

def query_completion(prompt: str, engine: str = 'gpt-3.5-turbo', temperature: float = 0.2, max_tokens: int = 1500, top_p: int = 1, frequency_penalty: float = 0.2, presence_penalty: float = 0) -> object:
    """
    Function for querying GPT-3.5 Turbo.
    """
    estimated_prompt_tokens = int(len(prompt.split()) * 1.6)
    estimated_answer_tokens = 2049 - estimated_prompt_tokens
    response = openai.ChatCompletion.create(
    model=engine,
    messages=[{"role": "user", "content": prompt}],
    temperature=temperature,
    max_tokens=min(4096-estimated_prompt_tokens-150, max_tokens),
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
    response_text = response['choices'][0]['message']['content'].strip()

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

> Deploying OpenAI on AWS Lambda can be a smart move for businesses looking to leverage the power of artificial intelligence without investing in expensive hardware or infrastructure. AWS Lambda is a serverless computing platform that allows developers to run code without managing servers. This means that businesses can easily deploy OpenAI models on AWS Lambda and scale up or down as needed, without worrying about server maintenance or capacity planning. Additionally, AWS Lambda offers pay-per-use pricing, which means that businesses only pay for the computing resources they use, making it a cost-effective solution for deploying OpenAI models. Overall, deploying OpenAI on AWS Lambda can help businesses streamline their AI initiatives and achieve faster time-to-market with minimal investment.