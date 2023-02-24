DB_URL=postgresql://root:123456@localhost:5433/simple_bank?sslmode=disable

postgres:
	docker run --name postgres -p 5433:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=123456 -d postgres:latest

createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres dropdb simple_bank

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

sqlc:
	sqlc generate

test:
	go test -v -cover ./...

.PHONY: postgrexs createdb dropdb migrateup migratedown sqlc