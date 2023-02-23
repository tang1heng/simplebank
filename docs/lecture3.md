# How to write & run database migration in Golang

https://github.com/golang-migrate/migrate

安装：

```bash
brew install golang-migrate
```

升级：

```bash
migrate -path db/migration -database "postgresql://root:123456@localhost:5433/simple_bank?sslmode=disable" -verbose up
```

降级：

```bash
migrate -path db/migration -database "postgresql://root:123456@localhost:5433/simple_bank?sslmode=disable" -verbose down
```