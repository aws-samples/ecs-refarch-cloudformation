REGION=ap-northeast-1
TEMPLATE_URL=https://s3-ap-southeast-2.amazonaws.com/zanui-infrastructure/cdp/$(NAME)

test:
	@find templates -iname "*.template" | xargs -I{} -n1 -t aws cloudformation validate-template --template-body file://{}

stack-deploy-source:
	aws s3 cp --recursive --exclude "*" --include "master.yaml" --include "infrastructure/*" --include "services/*" --include "stacks/$(NAME).json" . s3://zanui-infrastructure/cdp/$(NAME)

create-stack: stack-deploy-source
ifndef NAME
	    $(error NAME is undefined)
endif
ifndef ENVIRONMENT
	    ENVIRONMENT=staging
endif
	@echo Creating stack $(NAME)
	aws cloudformation create-stack --stack-name $(NAME) --template-url $(TEMPLATE_URL)/templates/master.yaml --capabilities CAPABILITY_IAM --parameters $(TEMPLATE_URL)/stacks/$(NAME).json

update-stack: stack-deploy-source
ifndef NAME
	$(error NAME is undefined)
endif
	@echo Update stack $(NAME)
	aws cloudformation update-stack --stack-name $(NAME) --template-url $(TEMPLATE_URL)/templates/master.yaml --capabilities CAPABILITY_IAM --parameters $(TEMPLATE_URL)/stacks/$(NAME).json

change-stack: stack-deploy-source
ifndef NAME
	$(error NAME is undefined)
endif
	@echo Change stack $(NAME)
	aws cloudformation create-change-set --stack-name $(NAME) --template-url $(TEMPLATE_URL)/templates/master.yaml --capabilities CAPABILITY_IAM --parameters $(TEMPLATE_URL)/stacks/$(NAME).json --change-set-name Update

markdown-update-template-index:
	@TEMPLATES=$(shell find templates -iname "*.template")
	@perl -i -0777 -pe "s/## Templates.*?##/## Templates\n\n| Template | Description |\n|---|---|\n:templates-toc:\n\n##/s" README.md
	@CONTENT = $(shell find . -iname "*.template" | xargs -I{} -n1 sh -c 'echo \| {} \| `jq .Description {}` \|')


setup:
	@port install jq
