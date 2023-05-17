# Create-AWS-Python-Layer

Work derived from https://github.com/erenyasarkurt/OpenAI-AWS-Lambda-Layer

## Requirements

install 'zip'

## Building

You can build the OpenAI layer yourself (requires Docker) and get the latest version and customize the Python version which you're building for:

```bash
$ cd openai-aws-lambda-layer
$ ./build/build.sh
# or specify Python version
$ ./build/build.sh 3.10
# or specify Python version and Architecture
$ ./build/build.sh 3.10 arm64
```

