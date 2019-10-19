### Deploy
.PHONY: push-image
push-image:
	apex infra apply -target=module.ecr -auto-approve
	sleep 5
	docker push \
		${AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}

.PHONY: apply-lambda
apply-lambda:
	apex infra apply -target=module.lambda_role -auto-approve
	sleep 5
	apex deploy \
		--set WEBHOOK_URL=${WEBHOOK_URL} \
		--set BUCKET_NAME=${BUCKET_NAME} notify-slack
	apex deploy \
		--set WEBHOOK_URL=${WEBHOOK_URL} \
		--set BUCKET_NAME=${BUCKET_NAME} check-result

.PHONY: infra-apply
infra-apply:
	apex infra apply -auto-approve

.PHONY: deploy
deploy: push-image apply-lambda infra-apply

### Destroy
.PHONY: destroy-lambda
destroy-lambda:
	apex delete -f
	sleep 5
	apex infra destroy -target=module.lambda_role -auto-approve

.PHONY: infra-destroy
infra-destroy:
	apex infra destroy -target=module.cloudwatch -target=module.s3 -auto-approve
	apex infra destroy -auto-approve

.PHONY: destroy
destroy: destroy-lambda infra-destroy

### Docker
.PHONY: docker-test
docker-test:
	cd python-batch && docker build -t test \
		--build-arg WEBHOOK_URL=${WEBHOOK_URL} \
    	--build-arg BUCKET_NAME=Undefined --no-cache .
	docker run -it --rm test
	docker rmi test

.PHONY: docker-build
docker-build:
	cd python-batch && docker build \
    	-t ${AWS_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG} \
    	--build-arg WEBHOOK_URL=${WEBHOOK_URL} \
    	--build-arg BUCKET_NAME=${BUCKET_NAME} --no-cache .
