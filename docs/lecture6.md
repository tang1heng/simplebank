# A clean way to implement database transaction in Golang

在 Golang 中实现数据库事务：

acid：

- a：原子性。
- c：一致性。
- i：隔离性。
- d：持久性。

运行 sql 事务：

```sql
BEGIN;
...
COMMIT;
    
BEGIN;
...
ROLLBACK;
```