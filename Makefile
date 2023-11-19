# Usage: make server-run type=setup|http|grpc|rabbitmq
server-run: 
	@echo "Running..."
	@go run cmd/server/main.go -type="${type}"

client-run: 
	@echo "Running..."
	@go run cmd/client/main.go

# @cp .env.example build/.env
server-build:
	@cp .env.example build/.env
	@go build -o build/tcc-server-application cmd/server/main.go

# @cp .env.example build/.env
client-build:
	@cp .env.example build/.env
	@go build -o build/tcc-client-application cmd/client/main.go

deps:
	go mod download
	go mod tidy

# Usage: make start service=service_name (optional)
start:
	@docker-compose up -d ${service}

stop:
	@docker-compose down

# Usage: make start service=service_name (optional)
start-with-build:
	@docker-compose up -d --build ${service}

docker-client-build:
	docker build -t tcc-client-application -f cmd/client/Dockerfile .

restart: 
	@docker-compose restart

proto-generate:
	@rm internal/apps/message_grpc.pb.go
	@rm internal/apps/message.pb.go
	protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative ./internal/apps/message.proto

remove-temporary-files:
	@rm -rf .tmp/*

load-testing:
	locust --host=http://0.0.0.0:3002

# Usage: make get-container-logs service=backend_service_name repeat=repetition_value
get-containers-logs:
	@docker-compose logs bff-app > logs/bff-app_${repeat}.txt
	@docker-compose logs ${service} > logs/${service}_${repeat}.txt

remove-containers-logs:
	@rm -rf logs/*

# Usage: make get-container logs service=backend_service_name repeat=repetition_value
proccess-log-values:
	go run cmd/logprocesser/main.go ./logs/${service}_${repeat}.txt