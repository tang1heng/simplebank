# Generate CRUD Golang code from SQL | Compare db/sql, gorm, sqlx & sqlc

CRUD:

- create: insert new records
- read: select or search records
- update: change some fields of the record
- delete: remove records

orm 框架：

- database/sql
  - 非常快和直接
  - 需要映射sql域到变量上
  - 容易造成错误，直到运行时才会捕捉

```golang
package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"strings"
)

var (
	ctx context.Context
	db  *sql.DB
)

func main() {
	age := 27
	rows, err := db.QueryContext(ctx, "SELECT name FROM users WHERE age=?", age)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	names := make([]string, 0)

	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			// Check for a scan error.
			// Query rows will be closed with defer.
			log.Fatal(err)
		}
		names = append(names, name)
	}
	// If the database is being written to ensure to check for Close
	// errors that may be returned from the driver. The query may
	// encounter an auto-commit error and be forced to rollback changes.
	rerr := rows.Close()
	if rerr != nil {
		log.Fatal(rerr)
	}

	// Rows.Err will report the last error encountered by Rows.Scan.
	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s are %d years old", strings.Join(names, ", "), age)
}
```

- gorm：https://gorm.io/zh_CN/docs/index.html
  - crud代码已经被实现，只需要非常短的生产代码
  - 必须学习用gorm的函数来写查询
  - 在高负载上运行速度缓慢

```golang
package main

import (
  "gorm.io/gorm"
  "gorm.io/driver/sqlite"
)

type Product struct {
  gorm.Model
  Code  string
  Price uint
}

func main() {
  db, err := gorm.Open(sqlite.Open("test.db"), &gorm.Config{})
  if err != nil {
    panic("failed to connect database")
  }

  // 迁移 schema
  db.AutoMigrate(&Product{})

  // Create
  db.Create(&Product{Code: "D42", Price: 100})

  // Read
  var product Product
  db.First(&product, 1) // 根据整型主键查找
  db.First(&product, "code = ?", "D42") // 查找 code 字段值为 D42 的记录

  // Update - 将 product 的 price 更新为 200
  db.Model(&product).Update("Price", 200)
  // Update - 更新多个字段
  db.Model(&product).Updates(Product{Price: 200, Code: "F42"}) // 仅更新非零值字段
  db.Model(&product).Updates(map[string]interface{}{"Price": 200, "Code": "F42"})

  // Delete - 删除 product
  db.Delete(&product, 1)
}
```

- sqlx: https://github.com/jmoiron/sqlx
  - 非常快、容易使用
  - 通过查询文本和结构体标签映射域

```golang
package main

import (
  "database/sql"
  "fmt"
  "log"

  _ "github.com/lib/pq"
  "github.com/jmoiron/sqlx"
)

type Person struct {
    FirstName string `db:"first_name"`
    LastName  string `db:"last_name"`
    Email     string
}

func main() {
  // this Pings the database trying to connect
  // use sqlx.Open() for sql.Open() semantics
  db, err := sqlx.Connect("postgres", "user=foo dbname=bar sslmode=disable")
  if err != nil {
    log.Fatalln(err)
  }

  // exec the schema or fail; multi-statement Exec behavior varies between
  // database drivers;  pq will exec them all, sqlite3 won't, ymmv
  db.MustExec(schema)

  tx := db.MustBegin()
  // Named queries can use structs, so if you have an existing struct (i.e. person := &Person{}) that you have populated, you can pass it in as &person
  tx.NamedExec("INSERT INTO person (first_name, last_name, email) VALUES (:first_name, :last_name, :email)", &Person{"Jane", "Citizen", "jane.citzen@example.com"})
  tx.Commit()
}
```

- sqlc: 
  - 非常快、容易使用
  - 只需要写sql，自动生成crud代码
  - 在生成代码之前捕捉sql查询错误

```bash
brew install sqlc
```

```sql
-- name: GetAuthor :one
SELECT * FROM authors
WHERE id = $1 LIMIT 1;

-- name: ListAuthors :many
SELECT * FROM authors
ORDER BY name;

-- name: CreateAuthor :one
INSERT INTO authors (
  name, bio
) VALUES (
  $1, $2
)
RETURNING *;

-- name: DeleteAuthor :exec
DELETE FROM authors
WHERE id = $1;
```
