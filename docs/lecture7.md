# DB transaction lock & How to handle deadlock in Golang

- 数据库事务锁
- golang 中如何解决死锁

行级锁：

```bash
SELECT id, owner, balance, currency, created_at
FROM accounts
WHERE id = $1
LIMIT 1 FOR UPDATE
```

事务1：

- insert into transfers
- insert into entries 1
- insert into entries 2
- select account 1 for update：等待事务2释放锁 
  - wait for sharelock on transaction 2 
  - transaction 2 wait for sharelock on transaction 1

事务2:

- insert into transfers
- insert into entries 1
- insert into entries 2
- select account 1 for update：等待事务1释放锁

死锁由于外键约束导致

解决方案：

```sql 
SELECT *
FROM accounts
WHERE id = $1
LIMIT 1 FOR NO KEY UPDATE;
```