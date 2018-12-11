NAME=staging
REGION=ap-northeast-1
TEMPLATE_URL=https://s3.amazonaws.com/zanui-cdp-infra/$(NAME)


test:
	tests/validate-templates.sh

stack-deploy-source: test
	aws s3 cp --recursive --exclude "*" --include "master.yaml" --include "infrastructure/*" --include "services/*" --include "stacks/$(NAME).json" . s3://zanui-cdp-infra/$(NAME)

create-stack: stack-deploy-source
ifndef NAME
	    $(error NAME is undefined)
endif
ifndef ENVIRONMENT
	    ENVIRONMENT=staging
endif
	@echo Creating stack $(NAME)
	aws cloudformation create-stack --region $(REGION) --stack-name $(NAME) --template-url $(TEMPLATE_URL)/master.yaml  --capabilities CAPABILITY_NAMED_IAM --debug

update-stack: stack-deploy-source
ifndef NAME
	$(error NAME is undefined)
endif
	@echo Update stack $(NAME)
	aws cloudformation update-stack --region $(REGION) --stack-name $(NAME) --template-url $(TEMPLATE_URL)/master.yaml --capabilities CAPABILITY_NAMED_IAM --debug

change-stack: stack-deploy-source
ifndef NAME
	$(error NAME is undefined)
endif
	@echo Change stack $(NAME)
	aws cloudformation create-change-set--region $(REGION)  --stack-name $(NAME) --template-url $(TEMPLATE_URL)/master.yaml --capabilities CAPABILITY_NAMED_IAM --parameters $(TEMPLATE_URL)/stacks/$(NAME).json --change-set-name Update

markdown-update-template-index:
	@TEMPLATES=$(shell find templates -iname "*.template")
	@perl -i -0777 -pe "s/## Templates.*?##/## Templates\n\n| Template | Description |\n|---|---|\n:templates-toc:\n\n##/s" README.md
	@CONTENT = $(shell find . -iname "*.template" | xargs -I{} -n1 sh -c 'echo \| {} \| `jq .Description {}` \|')


setup:
	@port install jq

# estimate-cost:
# 	@aws cloudformation estimate-template-cost \
# 		--template-body=file://$(cform) --output text --query 'Url'

# describe:
# 	@aws cloudformation describe-stacks --stack-name=$(STACK_NAME)

# events:
# 	@aws cloudformation describe-stack-events --stack-name=$(STACK_NAME)

# resources:
# 	@aws cloudformation describe-stack-resources --stack-name=$(STACK_NAME)